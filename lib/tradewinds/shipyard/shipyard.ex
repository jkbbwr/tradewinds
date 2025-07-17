defmodule Tradewinds.Shipyard do
  @moduledoc """
  Shipyard schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Port

  schema "shipyard" do
    field :max_ships, :integer
    field :production_type, Ecto.Enum, values: [:cutter]
    field :production_count, :integer
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
    |> cast(attrs, [:port_id, :max_ships, :production_type, :production_count])
    |> validate_required([:port_id, :max_ships, :production_type, :production_count])
  end
end
