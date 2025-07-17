defmodule Tradewinds.Trading.TraderInventory do
  @moduledoc """
  TraderInventory schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Item
  alias Tradewinds.Trading.Trader

  schema "trader_inventory" do
    field :stock, :integer
    belongs_to :trader, Trader
    belongs_to :item, Item

    timestamps()
  end

  @doc """
  Changeset for creating and updating trader inventory.
  """
  def changeset(trader_inventory, attrs) do
    trader_inventory
    |> cast(attrs, [:stock, :trader_id, :item_id])
    |> validate_required([:stock, :trader_id, :item_id])
  end
end
