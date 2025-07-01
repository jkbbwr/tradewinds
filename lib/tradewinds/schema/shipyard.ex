defmodule Tradewinds.Schema.Shipyard do
  use Tradewinds.Schema

  schema "shipyard" do
    belongs_to :port, Tradewinds.Schema.Port
    has_many :shipyard_inventory, Tradewinds.Schema.ShipyardInventory
    has_many :ships, through: [:shipyard_inventory, :ship]
    timestamps()
  end
end
