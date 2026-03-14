defmodule Tradewinds.LogisticsTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Logistics
  alias Tradewinds.Logistics.WarehouseInventory
  alias Tradewinds.Scope

  describe "warehouses" do
    test "fetch_warehouse/1 returns the warehouse" do
      warehouse = insert(:warehouse)
      assert {:ok, fetched} = Logistics.fetch_warehouse(warehouse.id)
      assert fetched.id == warehouse.id
    end

    test "fetch_warehouse/1 returns error if not found" do
      assert {:error, {:warehouse_not_found, _}} = Logistics.fetch_warehouse(Ecto.UUID.generate())
    end
  end

  describe "pricing" do
    alias Tradewinds.Logistics.Warehouse

    test "upgrade_cost/1 calculates correct cost based on tier" do
      assert Logistics.upgrade_cost(%Warehouse{level: 1}) == 100
      assert Logistics.upgrade_cost(%Warehouse{level: 2}) == 140
      assert Logistics.upgrade_cost(%Warehouse{level: 3}) == 195
      assert Logistics.upgrade_cost(%Warehouse{level: 4}) == 274
      assert Logistics.upgrade_cost(%Warehouse{level: 5}) == 384
    end

    test "upgrade_cost/1 fetches warehouse and returns calculated cost" do
      warehouse = insert(:warehouse, level: 3)
      assert {:ok, 195} = Logistics.upgrade_cost(warehouse.id)
    end

    test "upgrade_cost/1 returns error if warehouse not found" do
      assert {:error, {:warehouse_not_found, _}} = Logistics.upgrade_cost(Ecto.UUID.generate())
    end

    test "upkeep_cost/1 calculates correct total cost based on tier and capacity" do
      # Formula: Total = (Capacity * 0.08) + (Capacity * 0.01 * Tier^1.6)

      # Tier 1, Cap 100: (100 * 0.08) + (100 * 0.01 * 1^1.6) = 8 + 1 = 9
      assert Logistics.upkeep_cost(%Warehouse{level: 1, capacity: 100}) == 9

      # Tier 2, Cap 100: (100 * 0.08) + (100 * 0.01 * 2^1.6) = 8 + 3.03 = 11
      assert Logistics.upkeep_cost(%Warehouse{level: 2, capacity: 100}) == 11

      # Tier 3, Cap 100: (100 * 0.08) + (100 * 0.01 * 3^1.6) = 8 + 5.79 = 13
      assert Logistics.upkeep_cost(%Warehouse{level: 3, capacity: 100}) == 13

      # Tier 4, Cap 100: (100 * 0.08) + (100 * 0.01 * 4^1.6) = 8 + 9.18 = 17
      assert Logistics.upkeep_cost(%Warehouse{level: 4, capacity: 100}) == 17

      # Tier 5, Cap 100: (100 * 0.08) + (100 * 0.01 * 5^1.6) = 8 + 13.13 = 21
      assert Logistics.upkeep_cost(%Warehouse{level: 5, capacity: 100}) == 21

      # Tier 5, Cap 200: (200 * 0.08) + (200 * 0.01 * 5^1.6) = 16 + 26.26 = 42
      assert Logistics.upkeep_cost(%Warehouse{level: 5, capacity: 200}) == 42
    end

    test "upkeep_cost/1 fetches warehouse and returns calculated cost" do
      warehouse = insert(:warehouse, level: 3, capacity: 100)
      assert {:ok, 13} = Logistics.upkeep_cost(warehouse.id)
    end

    test "upkeep_cost/1 returns error if warehouse not found" do
      assert {:error, {:warehouse_not_found, _}} = Logistics.upkeep_cost(Ecto.UUID.generate())
    end
  end

  describe "growth and shrinkage" do
    test "create_warehouse/2 purchases a new warehouse and records metadata" do
      player = insert(:player)
      company = insert(:company, treasury: 5000)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)

      assert {:ok, warehouse} = Logistics.create_warehouse(scope, port.id)
      assert warehouse.port_id == port.id
      assert warehouse.level == 1

      # Check ledger metadata
      ledger =
        Repo.get_by(Tradewinds.Companies.Ledger,
          company_id: company.id,
          reason: :warehouse_purchase
        )

      assert ledger.meta["port_id"] == port.id
      assert ledger.meta["cost"] == 100
    end

    test "grow_warehouse/2 increases level and capacity and charges treasury" do
      player = insert(:player)
      company = insert(:company, treasury: 5000)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      warehouse = insert(:warehouse, company: company, level: 1, capacity: 1000)

      # level 1 upgrade cost is 100
      assert {:ok, updated_warehouse} = Logistics.grow_warehouse(scope, warehouse.id)

      assert updated_warehouse.level == 2
      assert updated_warehouse.capacity == 2000

      updated_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury < 5000

      # verify ledger entry and metadata
      ledger =
        Repo.get_by(Tradewinds.Companies.Ledger,
          company_id: company.id,
          reason: :warehouse_upgrade,
          reference_id: warehouse.id
        )

      assert ledger.meta["port_id"] == warehouse.port_id
      assert ledger.meta["warehouse_id"] == warehouse.id
      assert ledger.meta["new_level"] == 2
      assert ledger.meta["cost"] == 100
    end

    test "grow_warehouse/2 fails if insufficient funds" do
      player = insert(:player)
      # less than 100
      company = insert(:company, treasury: 50)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      warehouse = insert(:warehouse, company: company, level: 1, capacity: 1000)

      assert {:error, :insufficient_funds} = Logistics.grow_warehouse(scope, warehouse.id)

      reloaded = Repo.get(Tradewinds.Logistics.Warehouse, warehouse.id)
      assert reloaded.level == 1
    end

    test "shrink_warehouse/2 decreases level and capacity" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      warehouse = insert(:warehouse, company: company, level: 2, capacity: 2000)

      assert {:ok, updated_warehouse} = Logistics.shrink_warehouse(scope, warehouse.id)
      assert updated_warehouse.level == 1
      assert updated_warehouse.capacity == 1000
    end

    test "shrink_warehouse/2 fails if already at minimum tier" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      warehouse = insert(:warehouse, company: company, level: 1, capacity: 1000)

      assert {:error, :already_minimum_tier} = Logistics.shrink_warehouse(scope, warehouse.id)
    end

    test "shrink_warehouse/2 fails if inventory exceeds new capacity" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      warehouse = insert(:warehouse, company: company, level: 2, capacity: 2000)
      good = insert(:good)

      # Fill it with 1500, new capacity would be 1000
      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 1500)

      assert {:error, :capacity_exceeded_if_shrunk} =
               Logistics.shrink_warehouse(scope, warehouse.id)
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

      assert {:error, {:inventory_not_found, _}} =
               Logistics.remove_cargo(warehouse.id, good.id, 10)
    end
  end

  describe "transfer_to_ship/5" do
    test "successfully transfers cargo from warehouse to ship" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)
      warehouse = insert(:warehouse, port: port, company: company)

      ship =
        insert(:ship,
          status: :docked,
          port: port,
          company: company,
          ship_type: insert(:ship_type, capacity: 100)
        )

      good = insert(:good)

      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 50)

      assert {:ok, :transferred} =
               Logistics.transfer_to_ship(scope, warehouse.id, ship.id, good.id, 30)

      # Check warehouse inventory
      assert {:ok, 20} = Logistics.current_inventory_total(warehouse.id)

      # Check ship inventory
      assert {:ok, 30} = Tradewinds.Fleet.current_cargo_total(ship.id)
    end

    test "fails if ship is not at same port" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port1 = insert(:port)
      port2 = insert(:port)
      warehouse = insert(:warehouse, port: port1, company: company)
      ship = insert(:ship, status: :docked, port: port2, company: company)
      good = insert(:good)

      insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 50)

      assert {:error, :not_at_same_port} =
               Logistics.transfer_to_ship(scope, warehouse.id, ship.id, good.id, 30)
    end
  end
end
