defmodule Tradewinds.Shipyards.Inventory do
  use Tradewinds.Schema

  schema "shipyard_inventory" do
    belongs_to :shipyard, Tradewinds.Shipyards.Shipyard
    belongs_to :ship_type, Tradewinds.World.ShipType
    belongs_to :ship, Tradewinds.Fleet.Ship
    field :cost, :integer
    timestamps()
  end

  @doc """
  Builds a changeset for adding an unowned ship to a shipyard's inventory for sale.
  """
  def create_changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [:shipyard_id, :ship_type_id, :ship_id, :cost])
    |> validate_required([:shipyard_id, :ship_type_id, :ship_id, :cost])
    |> foreign_key_constraint(:shipyard_id)
    |> foreign_key_constraint(:ship_type_id)
    |> foreign_key_constraint(:ship_id)
  end
end
