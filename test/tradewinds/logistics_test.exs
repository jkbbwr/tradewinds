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

  describe "pricing" do
    alias Tradewinds.Logistics.Warehouse

    test "upgrade_cost/1 calculates correct cost based on tier" do
      assert Logistics.upgrade_cost(%Warehouse{level: 1}) == 100
      assert Logistics.upgrade_cost(%Warehouse{level: 2}) == 110
      assert Logistics.upgrade_cost(%Warehouse{level: 3}) == 121
      assert Logistics.upgrade_cost(%Warehouse{level: 4}) == 133
      assert Logistics.upgrade_cost(%Warehouse{level: 5}) == 146
    end

    test "upgrade_cost/1 fetches warehouse and returns calculated cost" do
      warehouse = insert(:warehouse, level: 3)
      assert {:ok, 121} = Logistics.upgrade_cost(warehouse.id)
    end

    test "upgrade_cost/1 returns error if warehouse not found" do
      assert {:error, :warehouse_not_found} = Logistics.upgrade_cost(Ecto.UUID.generate())
    end

    test "upkeep_cost/1 calculates correct total cost based on tier and capacity" do
      # Base rate per 10 capacity: 10 * 1.05^(tier-1)
      # Tier 1: 10
      assert Logistics.upkeep_cost(%Warehouse{level: 1, capacity: 100}) == 100
      # Tier 2: 10 * 1.05 = 10
      assert Logistics.upkeep_cost(%Warehouse{level: 2, capacity: 100}) == 100
      # Tier 3: 10 * 1.05^2 = 11.025 -> 11
      assert Logistics.upkeep_cost(%Warehouse{level: 3, capacity: 100}) == 110
      # Tier 4: 10 * 1.05^3 = 11.57625 -> 11
      assert Logistics.upkeep_cost(%Warehouse{level: 4, capacity: 100}) == 110
      # Tier 5: 10 * 1.05^4 = 12.1550625 -> 12
      assert Logistics.upkeep_cost(%Warehouse{level: 5, capacity: 100}) == 120
      # Test capacity variation
      assert Logistics.upkeep_cost(%Warehouse{level: 5, capacity: 200}) == 240
    end

    test "upkeep_cost/1 fetches warehouse and returns calculated cost" do
      warehouse = insert(:warehouse, level: 3, capacity: 100)
      assert {:ok, 110} = Logistics.upkeep_cost(warehouse.id)
    end

    test "upkeep_cost/1 returns error if warehouse not found" do
      assert {:error, :warehouse_not_found} = Logistics.upkeep_cost(Ecto.UUID.generate())
    end
  end

  describe "growth and shrinkage" do
    test "grow_warehouse/1 increases level and capacity and charges treasury" do
      company = insert(:company, treasury: 5000)
      warehouse = insert(:warehouse, company: company, level: 1, capacity: 1000)

      # level 1 upgrade cost is 100
      assert {:ok, updated_warehouse} = Logistics.grow_warehouse(warehouse.id)

      assert updated_warehouse.level == 2
      assert updated_warehouse.capacity == 2000

      updated_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury == 4900

      # verify ledger entry
      assert Repo.get_by(Tradewinds.Companies.Ledger,
               company_id: company.id,
               reference_type: "warehouse",
               reference_id: warehouse.id
             )
    end

    test "grow_warehouse/1 fails if insufficient funds" do
      # less than 100
      company = insert(:company, treasury: 50)
      warehouse = insert(:warehouse, company: company, level: 1, capacity: 1000)

      assert {:error, :insufficient_funds} = Logistics.grow_warehouse(warehouse.id)

      reloaded = Repo.get(Tradewinds.Logistics.Warehouse, warehouse.id)
      assert reloaded.level == 1
    end

    test "shrink_warehouse/1 decreases level and capacity" do
      warehouse = insert(:warehouse, level: 2, capacity: 2000)

      assert {:ok, updated_warehouse} = Logistics.shrink_warehouse(warehouse.id)
      assert updated_warehouse.level == 1
      assert updated_warehouse.capacity == 1000
    end

    test "shrink_warehouse/1 fails if already at minimum tier" do
      warehouse = insert(:warehouse, level: 1, capacity: 1000)

      assert {:error, :already_minimum_tier} = Logistics.shrink_warehouse(warehouse.id)
    end

    test "shrink_warehouse/1 fails if inventory exceeds new capacity" do
      warehouse = insert(:warehouse, level: 2, capacity: 2000)
      good = insert(:good)

      # Fill it with 1500, new capacity would be 1000
      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 1500)

      assert {:error, :capacity_exceeded_if_shrunk} = Logistics.shrink_warehouse(warehouse.id)
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
