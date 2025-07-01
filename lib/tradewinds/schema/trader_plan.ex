defmodule Tradewinds.Schema.TraderPlan do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Schema.Item
  alias Tradewinds.Schema.Trader

  schema "trader_plan" do
    belongs_to :trader, Trader
    belongs_to :item, Item

    field :average_acquisition_cost, :integer
    field :ideal_stock_level, :integer
    field :target_profit_margin, :float
    field :max_buy_sell_spread, :float
    field :price_elasticity, :float
    field :liquidity_factor, :float
    field :consumption_rate, :integer
    field :reversion_rate, :float
    field :regional_cost, :integer

    timestamps()
  end

  def changeset(trader_plan, attrs) do
    trader_plan
    |> cast(attrs, [
      :average_acquisition_cost,
      :ideal_stock_level,
      :target_profit_margin,
      :max_buy_sell_spread,
      :price_elasticity,
      :liquidity_factor,
      :consumption_rate,
      :reversion_rate,
      :regional_cost,
      :trader_id,
      :item_id
    ])
    |> validate_required([
      :average_acquisition_cost,
      :ideal_stock_level,
      :target_profit_margin,
      :max_buy_sell_spread,
      :price_elasticity,
      :liquidity_factor,
      :consumption_rate,
      :reversion_rate,
      :regional_cost,
      :trader_id,
      :item_id
    ])
  end
end
