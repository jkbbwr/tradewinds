defmodule Tradewinds.Shipyard.ShipyardInventory do
  @moduledoc """
  ShipyardInventory schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Shipyard
  alias Tradewinds.Ships.Ship

  schema "shipyard_inventory" do
    belongs_to :shipyard, Shipyard
    belongs_to :ship, Ship
    field :cost, :integer
  end

  @doc """
  Changeset for creating and updating shipyard inventory.
  """
  def changeset(shipyard_inventory, attrs) do
    shipyard_inventory
    |> cast(attrs, [:shipyard_id, :ship_id, :cost])
    |> validate_required([:shipyard_id, :ship_id, :cost])
  end

  @doc """
  Changeset for creating new shipyard inventory.
  """
  def create_changeset(shipyard_inventory, attrs) do
    shipyard_inventory
    |> cast(attrs, [:shipyard_id, :ship_id, :cost])
    |> validate_required([:shipyard_id, :ship_id, :cost])
  end
end
