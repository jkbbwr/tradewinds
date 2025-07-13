defmodule Tradewinds.ShipsTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Ships
  alias Tradewinds.Factory

  describe "ship movement" do
    test "set_sail/2 sets a ship to sail" do
      port1 = Factory.insert(:port)
      port2 = Factory.insert(:port)
      Factory.insert(:route, from: port1, to: port2, distance: 100)
      ship = Factory.insert(:ship, port: port1, speed: 10)

      assert {:ok, updated_ship} = Ships.set_sail(ship, port2)
      updated_ship = Repo.preload(updated_ship, :route)
      assert updated_ship.state == :at_sea
      assert updated_ship.route.from_id == port1.id
      assert updated_ship.route.to_id == port2.id
      assert updated_ship.arriving_at != nil
    end

    test "set_sail/2 returns error if no route exists" do
      port1 = Factory.insert(:port)
      port2 = Factory.insert(:port)
      ship = Factory.insert(:ship, port: port1)

      assert {:error, :route_not_found} = Ships.set_sail(ship, port2)
    end
  end

  describe "ship inventory" do
    test "load/3 adds items to a ship" do
      ship = Factory.insert(:ship, capacity: 100)
      item = Factory.insert(:item)

      assert {:ok, :loaded} = Ships.load(ship, item, 50)
      assert 50 == Ships.get_ship_total_cargo(ship.id)
    end

    test "load/3 returns error if not enough capacity" do
      ship = Factory.insert(:ship, capacity: 100)
      item = Factory.insert(:item)

      assert {:error, :not_enough_capacity} = Ships.load(ship, item, 150)
    end

    test "unload/3 removes items from a ship" do
      ship = Factory.insert(:ship)
      item = Factory.insert(:item)
      Factory.insert(:ship_inventory, ship: ship, item: item, amount: 100)

      assert {:ok, _} = Ships.unload(ship, item, 50)
      inventory = Repo.get_by(Tradewinds.Ships.ShipInventory, ship_id: ship.id, item_id: item.id)
      assert inventory.amount == 50
    end

    test "unload/3 removes inventory if amount is zero" do
      ship = Factory.insert(:ship)
      item = Factory.insert(:item)
      Factory.insert(:ship_inventory, ship: ship, item: item, amount: 100)

      assert {:ok, _} = Ships.unload(ship, item, 100)

      assert nil ==
               Repo.get_by(Tradewinds.Ships.ShipInventory, ship_id: ship.id, item_id: item.id)
    end

    test "unload/3 returns error if not enough inventory" do
      ship = Factory.insert(:ship)
      item = Factory.insert(:item)
      Factory.insert(:ship_inventory, ship: ship, item: item, amount: 50)

      assert {:error, :not_enough_inventory} = Ships.unload(ship, item, 100)
    end
  end

  describe "get_ship_total_cargo/1" do
    test "returns total cargo for a ship" do
      ship = Factory.insert(:ship)
      item1 = Factory.insert(:item)
      item2 = Factory.insert(:item)
      Factory.insert(:ship_inventory, ship: ship, item: item1, amount: 50)
      Factory.insert(:ship_inventory, ship: ship, item: item2, amount: 30)

      assert 80 == Ships.get_ship_total_cargo(ship.id)
    end

    test "returns 0 for a ship with no cargo" do
      ship = Factory.insert(:ship)
      assert 0 == Ships.get_ship_total_cargo(ship.id)
    end
  end
end
