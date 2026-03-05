defmodule Tradewinds.FleetTest do
  use Tradewinds.DataCase
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Fleet
  alias Tradewinds.Fleet.ShipCargo
  alias Tradewinds.Scope
  alias Tradewinds.Repo

  describe "ships" do
    test "fetch_ship/1 returns the ship" do
      ship = insert(:ship)
      assert {:ok, fetched_ship} = Fleet.fetch_ship(ship.id)
      assert fetched_ship.id == ship.id
    end

    test "fetch_ship/1 returns error if not found" do
      assert {:error, :ship_not_found} = Fleet.fetch_ship(Ecto.UUID.generate())
    end

    test "rename_ship/3 renames the ship if authorized" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      ship = insert(:ship, company: company, name: "Old Name")

      # Correctly construct scope
      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:ok, updated_ship} = Fleet.rename_ship(scope, ship.id, "New Name")
      assert updated_ship.name == "New Name"
    end

    test "rename_ship/3 fails if unauthorized" do
      player = insert(:player)
      other_company = insert(:company)
      ship = insert(:ship, company: other_company)

      # Not authorized
      scope = Scope.for(player: player, company_ids: [])

      assert {:error, :unauthorized} = Fleet.rename_ship(scope, ship.id, "New Name")
    end

    test "assign_ship/2 updates the company_id" do
      ship = insert(:ship)
      new_company = insert(:company)

      assert {:ok, updated_ship} = Fleet.assign_ship(ship.id, new_company.id)
      assert updated_ship.company_id == new_company.id
    end

    test "transfer_ship/3 transfers ship if authorized" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      ship = insert(:ship, company: company)
      new_company = insert(:company)

      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:ok, updated_ship} = Fleet.transfer_ship(scope, ship.id, new_company.id)
      assert updated_ship.company_id == new_company.id
    end

    test "transfer_ship/3 fails if unauthorized" do
      player = insert(:player)
      other_company = insert(:company)
      ship = insert(:ship, company: other_company)
      new_company = insert(:company)

      scope = Scope.for(player: player, company_ids: [])

      assert {:error, :unauthorized} = Fleet.transfer_ship(scope, ship.id, new_company.id)
    end
  end

  describe "transit" do
    test "transit_time/2 calculates correct ticks" do
      ship_type = insert(:ship_type, speed: 10)
      ship = insert(:ship, ship_type: ship_type)
      route = insert(:route, distance: 100)

      assert {:ok, 10} = Fleet.transit_time(ship.id, route.id)
    end

    test "transit_ship/2 starts traveling and schedules job" do
      port1 = insert(:port)
      port2 = insert(:port)
      route = insert(:route, from: port1, to: port2, distance: 100)
      ship_type = insert(:ship_type, speed: 10)
      ship = insert(:ship, status: :docked, port: port1, ship_type: ship_type)

      assert {:ok, updated_ship} = Fleet.transit_ship(ship.id, route.id)
      assert updated_ship.status == :traveling
      assert updated_ship.port_id == nil
      assert updated_ship.route_id == route.id
      assert updated_ship.arriving_at == 10

      assert_enqueued(
        worker: Tradewinds.Fleet.TransitJob,
        args: %{"ship_id" => ship.id}
      )
    end

    test "dock_ship/1 docks a traveling ship" do
      route = insert(:route)
      ship = insert(:ship, status: :traveling, port: nil, route: route, arriving_at: 0)

      assert {:ok, updated_ship} = Fleet.dock_ship(ship.id)
      assert updated_ship.status == :docked
      assert updated_ship.port_id == route.to_id
      assert updated_ship.route_id == nil
      assert updated_ship.arriving_at == nil
    end
  end

  describe "cargo" do
    test "add_cargo/3 adds cargo within capacity" do
      ship_type = insert(:ship_type, capacity: 100)
      ship = insert(:ship, ship_type: ship_type)
      good = insert(:good)

      assert {:ok, _} = Fleet.add_cargo(ship.id, good.id, 50)
      assert {:ok, 50} = Fleet.current_cargo_total(ship.id)
    end

    test "add_cargo/3 respects capacity limit" do
      ship_type = insert(:ship_type, capacity: 100)
      ship = insert(:ship, ship_type: ship_type)
      good = insert(:good)

      assert {:error, :capacity_exceeded} = Fleet.add_cargo(ship.id, good.id, 150)
    end

    test "remove_cargo/3 removes exact amount and deletes record" do
      ship = insert(:ship)
      good = insert(:good)
      insert(:ship_cargo, ship: ship, good: good, quantity: 50)

      assert {:ok, _} = Fleet.remove_cargo(ship.id, good.id, 50)
      assert {:ok, 0} = Fleet.current_cargo_total(ship.id)
      refute Repo.get_by(ShipCargo, ship_id: ship.id, good_id: good.id)
    end

    test "remove_cargo/3 reduces quantity" do
      ship = insert(:ship)
      good = insert(:good)
      insert(:ship_cargo, ship: ship, good: good, quantity: 50)

      assert {:ok, _} = Fleet.remove_cargo(ship.id, good.id, 20)
      assert {:ok, 30} = Fleet.current_cargo_total(ship.id)
    end
  end

  describe "transfer_to_warehouse" do
    test "successfully transfers cargo" do
      port = insert(:port)
      ship = insert(:ship, status: :docked, port: port)
      warehouse = insert(:warehouse, port: port, capacity: 1000)
      good = insert(:good)
      insert(:ship_cargo, ship: ship, good: good, quantity: 50)

      assert {:ok, :transferred} = Fleet.transfer_to_warehouse(ship.id, warehouse.id, good.id, 50)

      assert {:ok, 0} = Fleet.current_cargo_total(ship.id)
      assert {:ok, 50} = Tradewinds.Logistics.current_inventory_total(warehouse.id)
    end

    test "fails if ship is not docked" do
      port = insert(:port)
      route = insert(:route)
      ship = insert(:ship, status: :traveling, port: nil, route: route)
      warehouse = insert(:warehouse, port: port, capacity: 1000)
      good = insert(:good)

      assert {:error, :ship_not_docked} =
               Fleet.transfer_to_warehouse(ship.id, warehouse.id, good.id, 50)
    end

    test "fails if not at same port" do
      port1 = insert(:port)
      port2 = insert(:port)
      ship = insert(:ship, status: :docked, port: port1)
      warehouse = insert(:warehouse, port: port2, capacity: 1000)
      good = insert(:good)

      assert {:error, :not_at_same_port} =
               Fleet.transfer_to_warehouse(ship.id, warehouse.id, good.id, 50)
    end
  end
end
