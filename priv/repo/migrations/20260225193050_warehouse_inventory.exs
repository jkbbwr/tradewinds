defmodule Tradewinds.Repo.Migrations.WarehouseInventory do
  use Ecto.Migration

  def change do
    create table(:warehouse_inventory) do
      add :warehouse_id, references(:warehouse, on_delete: :delete_all), null: false
      add :good_id, references(:good, on_delete: :delete_all), null: false
      add :quantity, :integer, null: false
    end

    create unique_index(:warehouse_inventory, [:warehouse_id, :good_id])
    create constraint(:warehouse_inventory, :quantity_must_be_positive, check: "quantity > 0")
  end
end
