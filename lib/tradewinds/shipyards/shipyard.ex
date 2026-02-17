defmodule Tradewinds.Shipyards.Shipyard do
  use Tradewinds.Schema

  schema "shipyard" do
    belongs_to :port, Tradewinds.World.Port
    has_many :inventory, Tradewinds.Shipyards.Inventory

    timestamps()
  end

  @doc false
  def create_changeset(shipyard, attrs) do
    shipyard
    |> cast(attrs, [:port_id])
    |> validate_required([:port_id])
    |> foreign_key_constraint(:port_id)
    |> unique_constraint(:port_id)
  end
end
