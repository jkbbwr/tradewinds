defmodule Tradewinds.Commerce.TraderPosition do
  use Tradewinds.Schema

  schema "trader_position" do
    field :stock, :integer
    field :target_stock, :integer
    field :supply_rate, :float
    field :demand_rate, :float
    field :elasticity, :float
    field :spread, :float
    field :monthly_profit, :integer, default: 0

    belongs_to :trader, Tradewinds.Commerce.Trader
    belongs_to :port, Tradewinds.World.Port
    belongs_to :good, Tradewinds.World.Good

    timestamps()
  end

  @doc false
  def changeset(position, attrs) do
    position
    |> cast(attrs, [
      :trader_id,
      :port_id,
      :good_id,
      :stock,
      :target_stock,
      :supply_rate,
      :demand_rate,
      :elasticity,
      :spread,
      :monthly_profit
    ])
    |> validate_required([
      :trader_id,
      :port_id,
      :good_id,
      :stock,
      :target_stock,
      :supply_rate,
      :demand_rate,
      :elasticity,
      :spread,
      :monthly_profit
    ])
    |> validate_number(:stock, greater_than_or_equal_to: 0)
    |> validate_number(:target_stock, greater_than_or_equal_to: 0)
  end
end
