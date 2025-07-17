defmodule Tradewinds.Shipyard do
  @moduledoc """
  Shipyard schema.
  """
  use Tradewinds.Schema

  alias Tradewinds.World.Port

  schema "shipyard" do
    belongs_to :port, Port
    has_many :shipyard_inventory, Tradewinds.Shipyard.ShipyardInventory
    has_many :ships, through: [:shipyard_inventory, :ship]
    timestamps()
  end

  @doc """
  Changeset for creating a new shipyard.
  """
  def create_changeset(shipyard, attrs) do
    shipyard
    |> Ecto.Changeset.cast(attrs, [:port_id])
    |> Ecto.Changeset.validate_required([:port_id])
  end
end
