defmodule Tradewinds.ShipyardsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Shipyards
  alias Tradewinds.Shipyards.Inventory
  alias Tradewinds.Scope

  describe "shipyard_queries" do
    test "fetch_shipyard/1 returns the shipyard" do
      shipyard = insert(:shipyard)
      assert {:ok, fetched} = Shipyards.fetch_shipyard(shipyard.id)
      assert fetched.id == shipyard.id
    end

    test "fetch_shipyard/1 returns error if not found" do
      assert {:error, {:shipyard_not_found, _}} = Shipyards.fetch_shipyard(Ecto.UUID.generate())
    end

    test "fetch_shipyard_for_port/1 returns the shipyard" do
      port = insert(:port)
      shipyard = insert(:shipyard, port: port)
      assert {:ok, fetched} = Shipyards.fetch_shipyard_for_port(port.id)
      assert fetched.id == shipyard.id
    end

    test "fetch_shipyard_for_port/1 returns error if not found" do
      port = insert(:port)
      assert {:error, {:shipyard_not_found, _}} = Shipyards.fetch_shipyard_for_port(port.id)
    end

    test "fetch_shipyard_inventory/1 returns the inventory list" do
      shipyard = insert(:shipyard)
      inv1 = insert(:inventory, shipyard: shipyard)
      inv2 = insert(:inventory, shipyard: shipyard)

      assert {:ok, inventory} = Shipyards.fetch_shipyard_inventory(shipyard.id)
      assert length(inventory) == 2
      assert inv1.id in Enum.map(inventory, & &1.id)
      assert inv2.id in Enum.map(inventory, & &1.id)
    end

    test "has_stock?/2 returns true if stock exists" do
      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type)
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)

      assert Shipyards.has_stock?(shipyard.id, ship_type.id)
    end

    test "has_stock?/2 returns false if no stock" do
      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type)

      refute Shipyards.has_stock?(shipyard.id, ship_type.id)
    end

    test "create_ship/4 creates a new inventory item" do
      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type)
      ship = insert(:ship)
      cost = 1500

      assert {:ok, %Inventory{} = inventory} =
               Shipyards.create_ship(shipyard.id, ship_type.id, ship.id, cost)

      assert inventory.shipyard_id == shipyard.id
      assert inventory.ship_type_id == ship_type.id
      assert inventory.ship_id == ship.id
      assert inventory.cost == cost
    end

    test "produce_ships/1 builds up to 3 ships" do
      # Clean up any ship types inserted by seeds/other tests to ensure isolation
      Repo.delete_all(Tradewinds.World.ShipType)

      shipyard = insert(:shipyard)
      insert(:ship_type, capacity: 120) # 1 ship per tick on average

      # Should produce first ship
      Shipyards.produce_ships(shipyard.id)
      assert Repo.aggregate(Inventory, :count) == 1

      # Should produce second ship
      Shipyards.produce_ships(shipyard.id)
      assert Repo.aggregate(Inventory, :count) == 2

      # Should produce third ship
      Shipyards.produce_ships(shipyard.id)
      assert Repo.aggregate(Inventory, :count) == 3

      # Should NOT produce fourth ship
      Shipyards.produce_ships(shipyard.id)
      assert Repo.aggregate(Inventory, :count) == 3
    end

    test "produce_ships/1 fills stock faster for smaller ships" do
      Repo.delete_all(Tradewinds.World.ShipType)
      shipyard = insert(:shipyard)

      # Capacity 40 means ratio = 120/40 = 3.0. Should fill 3 ships in one tick.
      insert(:ship_type, capacity: 40)

      Shipyards.produce_ships(shipyard.id)
      assert Repo.aggregate(Inventory, :count) == 3
    end

    test "calculate_sell_price/2 returns correct price based on stock" do
      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type, base_price: 1000)

      # 0 stock: 90%
      assert {:ok, 900} = Shipyards.calculate_sell_price(ship_type.id, shipyard.id)

      # 1 stock: 80%
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)
      assert {:ok, 800} = Shipyards.calculate_sell_price(ship_type.id, shipyard.id)

      # 2 stock: 70%
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)
      assert {:ok, 700} = Shipyards.calculate_sell_price(ship_type.id, shipyard.id)

      # 5 stock: 40%
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)
      assert {:ok, 400} = Shipyards.calculate_sell_price(ship_type.id, shipyard.id)

      # 6 stock: 40% (min)
      insert(:inventory, shipyard: shipyard, ship_type: ship_type)
      assert {:ok, 400} = Shipyards.calculate_sell_price(ship_type.id, shipyard.id)
    end
  end

  describe "purchase_ship/4" do
    test "successfully purchases a ship" do
      player = insert(:player)
      company = insert(:company, treasury: 5000)
      insert(:director, company: company, player: player)

      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type)
      ship = insert(:ship)

      inventory =
        insert(:inventory, shipyard: shipyard, ship_type: ship_type, ship: ship, cost: 2000)

      scope = Scope.for(player: player, company_id: company.id)

      assert {:ok, purchased_ship} =
               Shipyards.purchase_ship(scope, shipyard.id, ship_type.id)

      assert purchased_ship.id == ship.id
      assert purchased_ship.company_id == company.id

      # Check inventory removed
      assert {:error, {:inventory_not_found, _}} =
               Repo.get(Inventory, inventory.id)
               |> Repo.ok_or({:inventory_not_found, inventory.id})

      # Check treasury deduction
      reloaded_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert reloaded_company.treasury == 5000 - 2000

      # Check ledger metadata
      ledger =
        Repo.get_by(Tradewinds.Companies.Ledger, company_id: company.id, reason: :ship_purchase)

      assert ledger.meta["shipyard_id"] == shipyard.id
      assert ledger.meta["ship_type_id"] == ship_type.id
      assert ledger.meta["cost"] == 2000
    end

    test "fails if insufficient funds" do
      player = insert(:player)
      # Not enough
      company = insert(:company, treasury: 100)
      insert(:director, company: company, player: player)

      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type)
      ship = insert(:ship, company: company)
      insert(:inventory, shipyard: shipyard, ship_type: ship_type, ship: ship, cost: 2000)

      scope = Scope.for(player: player, company_id: company.id)

      assert {:error, :insufficient_funds} =
               Shipyards.purchase_ship(scope, shipyard.id, ship_type.id)

      # Verify inventory still exists
      assert Repo.aggregate(Inventory, :count) == 1
    end

    test "fails if out of stock" do
      player = insert(:player)
      company = insert(:company, treasury: 5000)
      insert(:director, company: company, player: player)

      shipyard = insert(:shipyard)
      ship_type = insert(:ship_type)
      # No inventory

      scope = Scope.for(player: player, company_id: company.id)

      assert {:error, {:inventory_not_found, _}} =
               Shipyards.purchase_ship(scope, shipyard.id, ship_type.id)
    end
  end

  describe "sell_ship/3" do
    test "successfully sells a ship back to shipyard" do
      player = insert(:player)
      company = insert(:company, treasury: 1000)
      insert(:director, company: company, player: player)

      port = insert(:port)
      shipyard = insert(:shipyard, port: port)
      ship_type = insert(:ship_type, base_price: 1000)
      ship = insert(:ship, company: company, port: port, ship_type: ship_type, status: :docked)

      scope = Scope.for(player: player, company_id: company.id)

      # 0 stock -> 90% = 900
      assert {:ok, result} = Shipyards.sell_ship(scope, shipyard.id, ship.id)
      assert result.price == 900

      # Verify ship unowned
      reloaded_ship = Repo.get(Tradewinds.Fleet.Ship, ship.id)
      assert is_nil(reloaded_ship.company_id)

      # Verify inventory added
      assert Repo.get_by(Inventory, shipyard_id: shipyard.id, ship_id: ship.id)

      # Verify treasury increased
      reloaded_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert reloaded_company.treasury == 1900
    end

    test "fails if ship is at wrong port" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)

      port1 = insert(:port)
      port2 = insert(:port)
      shipyard = insert(:shipyard, port: port1)
      ship = insert(:ship, company: company, port: port2, status: :docked)

      scope = Scope.for(player: player, company_id: company.id)

      assert {:error, :not_at_shipyard} = Shipyards.sell_ship(scope, shipyard.id, ship.id)
    end

    test "fails if ship has cargo" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)

      port = insert(:port)
      shipyard = insert(:shipyard, port: port)
      ship = insert(:ship, company: company, port: port, status: :docked)
      good = insert(:good)
      insert(:ship_cargo, ship: ship, good: good, quantity: 10)

      scope = Scope.for(player: player, company_id: company.id)

      assert {:error, :ship_not_empty} = Shipyards.sell_ship(scope, shipyard.id, ship.id)
    end
  end
end
