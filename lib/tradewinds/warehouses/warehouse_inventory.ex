defmodule Tradewinds.Warehouses.WarehouseInventory do
  @moduledoc """
  WarehouseInventory schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Warehouses.Warehouse
  alias Tradewinds.World.Item

  schema "warehouse_inventory" do
    belongs_to :warehouse, Warehouse, foreign_key: :warehouse_id
    belongs_to :item, Item, foreign_key: :item_id
    field :amount, :integer

    timestamps()
  end

  @doc """
  Builds a changeset for the warehouse_inventory schema.
  """
  def changeset(warehouse_inventory, attrs) do
    warehouse_inventory
    |> cast(attrs, [:warehouse_id, :item_id, :amount])
    |> validate_required([:warehouse_id, :item_id, :amount])
    |> unique_constraint([:warehouse_id, :item_id])
  end

  @doc """
  Changeset for updating the amount of an item in a warehouse's inventory.
  """
  def update_amount_changeset(warehouse_inventory, amount) do
    warehouse_inventory
    |> cast(%{amount: amount}, [:amount])
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end

  @doc """
  Changeset for creating new warehouse inventory.
  """
  def create_changeset(warehouse_inventory, attrs) do
    warehouse_inventory
    |> cast(attrs, [:warehouse_id, :item_id, :amount])
    |> validate_required([:warehouse_id, :item_id, :amount])
  end
end
