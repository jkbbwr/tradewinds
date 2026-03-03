defmodule Tradewinds.Logistics.WarehouseInventory do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "warehouse_inventory" do
    field :quantity, :integer

    belongs_to :warehouse, Tradewinds.Logistics.Warehouse
    belongs_to :good, Tradewinds.World.Good
  end

  @doc """
  Builds a changeset for creating a new inventory record within a warehouse.
  Enforces uniqueness per warehouse/good combination.
  """
  def create_changeset(warehouse_inventory, attrs) do
    warehouse_inventory
    |> cast(attrs, [:quantity, :warehouse_id, :good_id])
    |> validate_required([:quantity, :warehouse_id, :good_id])
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:warehouse_id)
    |> foreign_key_constraint(:good_id)
    |> unique_constraint([:warehouse_id, :good_id],
      name: :warehouse_inventory_warehouse_id_good_id_index
    )
    |> check_constraint(:quantity, name: :quantity_must_be_positive)
  end

  @doc """
  Builds a changeset for updating the quantity of an existing inventory record.
  """
  def update_quantity_changeset(warehouse_inventory, attrs) do
    warehouse_inventory
    |> cast(attrs, [:quantity])
    |> validate_required([:quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> check_constraint(:quantity, name: :quantity_must_be_positive)
  end
end
