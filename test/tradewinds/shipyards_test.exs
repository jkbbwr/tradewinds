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
      assert {:error, :shipyard_not_found} = Shipyards.fetch_shipyard(Ecto.UUID.generate())
    end

    test "fetch_shipyard_for_port/1 returns the shipyard" do
      port = insert(:port)
      shipyard = insert(:shipyard, port: port)
      assert {:ok, fetched} = Shipyards.fetch_shipyard_for_port(port)
      assert fetched.id == shipyard.id
    end

    test "fetch_shipyard_for_port/1 returns error if not found" do
      port = insert(:port)
      assert {:error, :shipyard_not_found} = Shipyards.fetch_shipyard_for_port(port)
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
      assert {:error, :inventory_not_found} =
               Repo.get(Inventory, inventory.id) |> Repo.ok_or(:inventory_not_found)

      # Check treasury deduction
      reloaded_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert reloaded_company.treasury == 5000 - 2000
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

      assert {:error, :inventory_not_found} =
               Shipyards.purchase_ship(scope, shipyard.id, ship_type.id)
    end
  end
end
