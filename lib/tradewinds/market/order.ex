defmodule Tradewinds.Market.Order do
  use Tradewinds.Schema

  schema "order_book" do
    field :side, Ecto.Enum, values: [:buy, :sell]
    field :price, :integer
    field :total, :integer
    field :remaining, :integer
    field :created_at, :utc_datetime_usec
    field :expires_at, :utc_datetime_usec
    field :posted_reputation, :integer
    field :status, Ecto.Enum, values: [:open, :filled, :cancelled, :expired], default: :open

    belongs_to :company, Tradewinds.Companies.Company
    belongs_to :trader, Tradewinds.Trade.Trader
    belongs_to :port, Tradewinds.World.Port
    belongs_to :good, Tradewinds.World.Good

    timestamps()
  end

  @doc """
  Builds a changeset for initially posting an order to the market.
  Calculates the initial `remaining` quantity from the `total`.
  """
  def create_changeset(order, attrs) do
    order
    |> cast(attrs, [
      :company_id,
      :trader_id,
      :port_id,
      :good_id,
      :side,
      :price,
      :total,
      :created_at,
      :expires_at,
      :posted_reputation
    ])
    |> validate_required([
      :port_id,
      :good_id,
      :side,
      :price,
      :total,
      :created_at,
      :expires_at,
      :posted_reputation
    ])
    |> validate_company_or_trader()
    |> put_change(:remaining, attrs[:total] || attrs["total"])
    |> put_change(:status, :open)
    |> validate_inclusion(:side, [:buy, :sell])
    |> validate_inclusion(:status, [:open, :filled, :cancelled, :expired])
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:total, greater_than: 0)
    |> foreign_key_constraint(:company_id)
    |> foreign_key_constraint(:trader_id)
    |> foreign_key_constraint(:port_id)
    |> foreign_key_constraint(:good_id)
    |> check_constraint(:company_id,
      name: :company_or_trader_id_present,
      message: "must have either company_id or trader_id, but not both"
    )
  end

  defp validate_company_or_trader(changeset) do
    company_id = get_field(changeset, :company_id)
    trader_id = get_field(changeset, :trader_id)

    case {company_id, trader_id} do
      {nil, nil} ->
        add_error(changeset, :company_id, "must have either company_id or trader_id")

      {cid, tid} when cid != nil and tid != nil ->
        add_error(changeset, :company_id, "cannot have both company_id and trader_id")

      _ ->
        changeset
    end
  end

  @doc """
  Builds a changeset to transition the order's status (e.g. to cancelled or expired).
  """
  def update_status_changeset(order, status) when status in [:filled, :cancelled, :expired] do
    order
    |> cast(%{status: status}, [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, [:filled, :cancelled, :expired])
  end

  @doc """
  Builds a changeset to decrement the remaining quantity of an order after a partial fill.
  """
  def update_remaining_changeset(order, new_remaining) do
    order
    |> cast(%{remaining: new_remaining}, [:remaining])
    |> validate_required([:remaining])
    |> validate_number(:remaining,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: order.total
    )
  end
end
