defmodule Tradewinds.Schema.TraderInventory do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Schema.Item
  alias Tradewinds.Schema.Trader

  schema "trader_inventory" do
    field :stock, :integer
    belongs_to :trader, Trader
    belongs_to :item, Item

    timestamps()
  end

  def changeset(trader_inventory, attrs) do
    trader_inventory
    |> cast(attrs, [:stock, :trader_id, :item_id])
    |> validate_required([:stock, :trader_id, :item_id])
  end
end
