defmodule Tradewinds.LogisticsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Logistics
  alias Tradewinds.Logistics.WarehouseInventory

  describe "warehouses" do
    test "fetch_warehouse/1 returns the warehouse" do
      warehouse = insert(:warehouse)
      assert {:ok, fetched} = Logistics.fetch_warehouse(warehouse.id)
      assert fetched.id == warehouse.id
    end

    test "fetch_warehouse/1 returns error if not found" do
      assert {:error, :warehouse_not_found} = Logistics.fetch_warehouse(Ecto.UUID.generate())
    end
  end

  describe "cargo" do
    test "add_cargo/3 successfully adds new cargo" do
      warehouse = insert(:warehouse, capacity: 100)
      good = insert(:good)

      assert {:ok, _} = Logistics.add_cargo(warehouse.id, good.id, 50)
      assert {:ok, 50} = Logistics.current_inventory_total(warehouse.id)
    end

    test "add_cargo/3 increments existing cargo" do
      warehouse = insert(:warehouse, capacity: 100)
      good = insert(:good)

      Logistics.add_cargo(warehouse.id, good.id, 50)
      assert {:ok, _} = Logistics.add_cargo(warehouse.id, good.id, 25)
      assert {:ok, 75} = Logistics.current_inventory_total(warehouse.id)
      
      inventory = Repo.get_by(WarehouseInventory, warehouse_id: warehouse.id, good_id: good.id)
      assert inventory.quantity == 75
    end

    test "add_cargo/3 returns error if capacity exceeded" do
      warehouse = insert(:warehouse, capacity: 100)
      good = insert(:good)

      assert {:error, :capacity_exceeded} = Logistics.add_cargo(warehouse.id, good.id, 101)
    end

    test "remove_cargo/3 successfully removes exact amount, deleting record" do
      warehouse = insert(:warehouse)
      good = insert(:good)
      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 50)

      assert {:ok, _} = Logistics.remove_cargo(warehouse.id, good.id, 50)
      assert {:ok, 0} = Logistics.current_inventory_total(warehouse.id)
      refute Repo.get_by(WarehouseInventory, warehouse_id: warehouse.id, good_id: good.id)
    end

    test "remove_cargo/3 successfully reduces amount" do
      warehouse = insert(:warehouse)
      good = insert(:good)
      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 50)

      assert {:ok, _} = Logistics.remove_cargo(warehouse.id, good.id, 20)
      assert {:ok, 30} = Logistics.current_inventory_total(warehouse.id)
      
      inventory = Repo.get_by(WarehouseInventory, warehouse_id: warehouse.id, good_id: good.id)
      assert inventory.quantity == 30
    end

    test "remove_cargo/3 fails if insufficient cargo" do
      warehouse = insert(:warehouse)
      good = insert(:good)
      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 20)

      assert {:error, :insufficient_inventory} = Logistics.remove_cargo(warehouse.id, good.id, 30)
    end

    test "remove_cargo/3 fails if cargo not found" do
      warehouse = insert(:warehouse)
      good = insert(:good)

      assert {:error, :inventory_not_found} = Logistics.remove_cargo(warehouse.id, good.id, 10)
    end
  end
end
