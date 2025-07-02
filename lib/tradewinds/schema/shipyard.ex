defmodule Tradewinds.Schema.Shipyard do
  use Tradewinds.Schema

  schema "shipyard" do
    belongs_to :port, Tradewinds.Schema.Port
    has_many :shipyard_inventory, Tradewinds.Schema.ShipyardInventory
    has_many :ships, through: [:shipyard_inventory, :ship]
    timestamps()
  end

  def create_changeset(shipyard, attrs) do
    shipyard
    |> Ecto.Changeset.cast(attrs, [:port_id])
    |> Ecto.Changeset.validate_required([:port_id])
  end
end
