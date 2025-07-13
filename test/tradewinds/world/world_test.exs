defmodule Tradewinds.WorldTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.World
  alias Tradewinds.Factory

  describe "routes" do
    test "find_route/2 finds a route" do
      port1 = Factory.insert(:port)
      port2 = Factory.insert(:port)
      route = Factory.insert(:route, from: port1, to: port2)

      assert {:ok, found_route} = World.find_route(port1.id, port2.id)
      assert found_route.id == route.id
    end

    test "find_route/2 finds a route in reverse" do
      port1 = Factory.insert(:port)
      port2 = Factory.insert(:port)
      route = Factory.insert(:route, from: port1, to: port2)

      assert {:ok, found_route} = World.find_route(port2.id, port1.id)
      assert found_route.id == route.id
    end

    test "find_route/2 returns error if no route exists" do
      port1 = Factory.insert(:port)
      port2 = Factory.insert(:port)

      assert {:error, :route_not_found} = World.find_route(port1.id, port2.id)
    end

    test "routes_from/1 returns all routes from a port" do
      port1 = Factory.insert(:port)
      port2 = Factory.insert(:port)
      port3 = Factory.insert(:port)
      route1 = Factory.insert(:route, from: port1, to: port2)
      route2 = Factory.insert(:route, from: port1, to: port3)

      routes = World.routes_from(port1.id)
      assert length(routes) == 2
      assert Enum.map(routes, & &1.id) == [route1.id, route2.id]
    end
  end

  describe "items" do
    test "fetch_item/1 returns an item" do
      item = Factory.insert(:item)
      assert {:ok, fetched_item} = World.fetch_item(item.id)
      assert fetched_item.id == item.id
    end
  end

  describe "ports" do
    test "list_ports/0 returns all ports" do
      current_port_count = length(World.list_ports())
      Factory.insert_list(3, :port)
      assert length(World.list_ports()) == current_port_count + 3
    end

    test "fetch_port/1 returns a port" do
      port = Factory.insert(:port)
      assert {:ok, fetched_port} = World.fetch_port(port.id)
      assert fetched_port.id == port.id
    end
  end

  describe "countries" do
    test "list_countries/0 returns all countries" do
      current_country_count = length(World.list_countries())
      Factory.insert_list(3, :country)
      assert length(World.list_countries()) == current_country_count + 3
    end

    test "fetch_country/1 returns a country" do
      country = Factory.insert(:country)
      assert {:ok, fetched_country} = World.fetch_country(country.id)
      assert fetched_country.id == country.id
    end
  end
end
