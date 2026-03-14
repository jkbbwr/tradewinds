defmodule Tradewinds.Trade.TraderPosition do
  use Tradewinds.Schema

  schema "trader_position" do
    field :stock, :integer
    field :target_stock, :integer
    field :supply_rate, :float
    field :demand_rate, :float
    field :elasticity, :float
    field :spread, :float
    field :quarterly_profit, :integer, default: 0

    belongs_to :trader, Tradewinds.Trade.Trader
    belongs_to :port, Tradewinds.World.Port
    belongs_to :good, Tradewinds.World.Good

    timestamps()
  end

  @doc """
  Builds a changeset for defining an NPC Trader's inventory pool and 
  economic parameters for a specific good at a specific port.
  """
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
      :quarterly_profit
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
      :quarterly_profit
    ])
    |> validate_number(:stock, greater_than_or_equal_to: 0)
    |> validate_number(:target_stock, greater_than_or_equal_to: 0)
  end

  @doc """
  Builds a changeset for updating the stock amount.
  """
  def update_stock_changeset(position, attrs) do
    position
    |> cast(attrs, [:stock])
    |> validate_required([:stock])
    |> validate_number(:stock, greater_than_or_equal_to: 0)
  end

  @doc """
  Builds a changeset for the daily simulation update, which can modify stock, target_stock, and spread.
  """
  def update_simulation_changeset(position, attrs) do
    position
    |> cast(attrs, [:stock, :target_stock, :spread])
    |> validate_required([:stock, :target_stock, :spread])
    |> validate_number(:stock, greater_than_or_equal_to: 0)
    |> validate_number(:target_stock, greater_than_or_equal_to: 0)
    |> validate_number(:spread, greater_than_or_equal_to: 0.0)
  end
end
