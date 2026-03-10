defmodule TradewindsWeb.WorldControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Factory

  setup %{conn: conn} do
    port = Factory.insert(:port)
    good = Factory.insert(:good)
    ship_type = Factory.insert(:ship_type)
    port_to = Factory.insert(:port)
    route = Factory.insert(:route, from: port, to: port_to, distance: 100)
    
    %{
      conn: conn,
      port: port,
      good: good,
      ship_type: ship_type,
      route: route
    }
  end

  describe "GET /api/v1/world/ports" do
    test "lists ports", %{conn: conn, port: port} do
      conn = get(conn, ~p"/api/v1/world/ports")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, fn p -> p["id"] == port.id end)
    end
  end

  describe "GET /api/v1/world/ports/:id" do
    test "gets a port", %{conn: conn, port: port} do
      conn = get(conn, ~p"/api/v1/world/ports/#{port.id}")
      data = json_response(conn, 200)["data"]
      assert data["id"] == port.id
    end
  end

  describe "GET /api/v1/world/goods" do
    test "lists goods", %{conn: conn, good: good} do
      conn = get(conn, ~p"/api/v1/world/goods")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, fn g -> g["id"] == good.id end)
    end
  end

  describe "GET /api/v1/world/goods/:id" do
    test "gets a good", %{conn: conn, good: good} do
      conn = get(conn, ~p"/api/v1/world/goods/#{good.id}")
      data = json_response(conn, 200)["data"]
      assert data["id"] == good.id
    end
  end

  describe "GET /api/v1/world/ship-types" do
    test "lists ship types", %{conn: conn, ship_type: ship_type} do
      conn = get(conn, ~p"/api/v1/world/ship-types")
      data = json_response(conn, 200)["data"]
      assert Enum.any?(data, fn st -> st["id"] == ship_type.id end)
    end
  end

  describe "GET /api/v1/world/ship-types/:id" do
    test "gets a ship type", %{conn: conn, ship_type: ship_type} do
      conn = get(conn, ~p"/api/v1/world/ship-types/#{ship_type.id}")
      data = json_response(conn, 200)["data"]
      assert data["id"] == ship_type.id
    end
  end

  describe "GET /api/v1/world/routes" do
    test "lists routes", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/world/routes")
      data = json_response(conn, 200)["data"]
      assert length(data) > 0
    end
  end

  describe "GET /api/v1/world/routes/:id" do
    test "gets a route", %{conn: conn, route: route} do
      conn = get(conn, ~p"/api/v1/world/routes/#{route.id}")
      data = json_response(conn, 200)["data"]
      assert data["id"] == route.id
    end
  end
end
