defmodule Tradewinds.Companies.Ledger do
  use Tradewinds.Schema

  schema "company_ledger" do
    field :occurred_at, :utc_datetime_usec
    field :amount, :integer

    field :reason, Ecto.Enum,
      values: [
        :initial_deposit,
        :transfer,
        :ship_purchase,
        :ship_sale,
        :warehouse_purchase,
        :tax,
        :market_trade,
        :market_listing_fee,
        :market_penalty_fine,
        :warehouse_upgrade,
        :warehouse_upkeep,
        :ship_upkeep,
        :npc_trade,
        :bailout,
        :passenger_fare
      ]

    field :reference_type, Ecto.Enum,
      values: [:market, :ship, :warehouse, :order, :system, :passenger]

    field :reference_id, :binary_id
    field :idempotency_key, :string
    field :meta, :map

    belongs_to :company, Tradewinds.Companies.Company

    timestamps(updated_at: false)
  end

  @doc """
  Builds a changeset for a new immutable ledger entry representing a financial event.
  """
  def create_changeset(ledger, attrs) do
    ledger
    |> cast(attrs, [
      :company_id,
      :occurred_at,
      :amount,
      :reason,
      :reference_type,
      :reference_id,
      :idempotency_key,
      :meta
    ])
    |> validate_required([
      :company_id,
      :occurred_at,
      :amount,
      :reason,
      :reference_type,
      :reference_id,
      :idempotency_key
    ])
    |> validate_number(:amount, not_equal_to: 0)
    |> unique_constraint(:idempotency_key)
  end
end
