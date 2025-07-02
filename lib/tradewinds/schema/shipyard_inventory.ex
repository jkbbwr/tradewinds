defmodule Tradewinds.Schema.ShipyardInventory do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "shipyard_inventory" do
    belongs_to :shipyard, Tradewinds.Schema.Shipyard
    belongs_to :ship, Tradewinds.Schema.Ship
    field :cost, :integer
  end

  def changeset(shipyard_inventory, attrs) do
    shipyard_inventory
    |> cast(attrs, [:shipyard_id, :ship_id, :cost])
    |> validate_required([:shipyard_id, :ship_id, :cost])
  end

  def create_changeset(shipyard_inventory, attrs) do
    shipyard_inventory
    |> cast(attrs, [:shipyard_id, :ship_id, :cost])
    |> validate_required([:shipyard_id, :ship_id, :cost])
  end
end
