defmodule Tradewinds.Economy.Shock do
  use Tradewinds.Schema

  schema "economy_shocks" do
    field :name, :string
    field :description, :string
    field :status, Ecto.Enum, values: [:pending, :active, :paused, :expired], default: :pending

    field :start_time, :utc_datetime_usec
    field :end_time, :utc_datetime_usec

    field :demand_modifier, :integer, default: 10_000
    field :supply_modifier, :integer, default: 10_000
    field :price_modifier, :integer, default: 10_000
    field :volatility_modifier, :integer, default: 10_000

    belongs_to :port, Tradewinds.World.Port
    belongs_to :good, Tradewinds.World.Good

    timestamps()
  end

  @doc """
  Builds a changeset for creating or updating an Economy Shock.
  Modifiers are stored in Basis Points (BPS) where 10,000 = 1.0x.
  """
  def changeset(shock, attrs) do
    shock
    |> cast(attrs, [
      :name,
      :description,
      :status,
      :port_id,
      :good_id,
      :start_time,
      :end_time,
      :demand_modifier,
      :supply_modifier,
      :price_modifier,
      :volatility_modifier
    ])
    |> validate_required([:name, :status, :start_time])
    |> validate_number(:demand_modifier, greater_than: 0)
    |> validate_number(:supply_modifier, greater_than: 0)
    |> validate_number(:price_modifier, greater_than: 0)
    |> validate_number(:volatility_modifier, greater_than: 0)
  end
end
