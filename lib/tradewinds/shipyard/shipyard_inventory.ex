defmodule Tradewinds.Shipyard.ShipyardInventory do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Shipyard
  alias Tradewinds.Fleet.Ship

  schema "shipyard_inventory" do
    belongs_to :shipyard, Shipyard
    belongs_to :ship, Ship
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
