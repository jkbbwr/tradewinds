defmodule Tradewinds.Schema.WarehouseInventory do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "warehouse_inventory" do
    belongs_to :warehouse, Tradewinds.Schema.Warehouse, foreign_key: :warehouse_id
    belongs_to :item, Tradewinds.Schema.Item, foreign_key: :item_id
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
end
