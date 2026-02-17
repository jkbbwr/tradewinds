defmodule Tradewinds.Shipyards.Inventory do
  use Tradewinds.Schema

  schema "shipyard_inventory" do
    belongs_to :shipyard, Tradewinds.Shipyards.Shipyard
    belongs_to :ship_type, Tradewinds.World.ShipType
    has_one :ship, Tradewinds.World.Ship
    field :cost, :integer
    timestamps()
  end

  @doc false
  def create_changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [:shipyard_id, :ship_type_id, :ship_id, :cost])
    |> validate_required([:shipyard_id, :ship_type_id, :ship_id, :cost])
    |> foreign_key_constraint(:shipyard_id)
    |> foreign_key_constraint(:ship_type_id)
    |> foreign_key_constraint(:ship_id)
  end
end
