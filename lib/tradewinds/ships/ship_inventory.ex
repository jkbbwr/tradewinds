defmodule Tradewinds.Ships.ShipInventory do
  @moduledoc """
  ShipInventory schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Item
  alias Tradewinds.Ships.Ship

  schema "ship_inventory" do
    belongs_to :item, Item, foreign_key: :item_id
    belongs_to :ship, Ship, foreign_key: :ship_id
    field :amount, :integer

    timestamps()
  end

  @doc """
  Builds a changeset for the ship_inventory schema.
  """
  def changeset(ship_inventory, attrs) do
    ship_inventory
    |> cast(attrs, [:item_id, :ship_id, :amount])
    |> validate_required([:item_id, :ship_id, :amount])
  end

  @doc """
  Changeset for updating the amount of an item in a ship's inventory.
  """
  def update_amount_changeset(ship_inventory, amount) do
    ship_inventory
    |> changeset(%{amount: amount})
  end
end
