defmodule TradewindsWeb.ShipControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Companies
  alias Tradewinds.Factory

  setup %{conn: conn} do
    {:ok, player} = Accounts.register("Director", "director@example.com", "password123")
    {:ok, player} = Accounts.enable(player)
    {:ok, auth_token} = Accounts.authenticate("director@example.com", "password123")

    port = Factory.insert(:port)
    route = Factory.insert(:route, from: port, to: Factory.insert(:port))
    good = Factory.insert(:good)
    ship_type = Factory.insert(:ship_type)

    scope = Tradewinds.Scope.for_player(player)
    {:ok, company} = Companies.create(scope, "Ship Co", "SHIP1", port.id)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{auth_token.token}")
      |> put_req_header("tradewinds-company-id", company.id)

    %{
      conn: conn,
      company: company,
      player: player,
      port: port,
      route: route,
      good: good,
      ship_type: ship_type,
      scope: %{scope | company_id: company.id}
    }
  end

  describe "GET /api/v1/ships" do
    test "returns empty list when company has no ships", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/ships")
      assert json_response(conn, 200)["data"] == []
    end

    test "returns list of ships", %{
      conn: conn,
      company: company,
      ship_type: ship_type,
      port: port
    } do
      ship =
        Factory.insert(:ship, company: company, ship_type: ship_type, port: port, name: "Ship 1")

      conn = get(conn, ~p"/api/v1/ships")
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["id"] == ship.id
      assert Enum.at(data, 0)["name"] == "Ship 1"
    end
  end

  describe "GET /api/v1/ships/:id" do
    test "returns ship details", %{conn: conn, company: company, ship_type: ship_type, port: port} do
      ship =
        Factory.insert(:ship, company: company, ship_type: ship_type, port: port, name: "Ship 1")

      conn = get(conn, ~p"/api/v1/ships/#{ship.id}")
      assert %{"id" => id, "name" => "Ship 1"} = json_response(conn, 200)["data"]
      assert id == ship.id
    end

    test "returns 404 when ship not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/ships/#{Ecto.UUID.generate()}")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/ships/:id/inventory" do
    test "returns ship inventory", %{
      conn: conn,
      company: company,
      ship_type: ship_type,
      port: port,
      good: good
    } do
      ship = Factory.insert(:ship, company: company, ship_type: ship_type, port: port)
      Factory.insert(:ship_cargo, ship: ship, good: good, quantity: 100)

      conn = get(conn, ~p"/api/v1/ships/#{ship.id}/inventory")
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["good_id"] == good.id
      assert Enum.at(data, 0)["quantity"] == 100
    end

    test "returns 404 when ship not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/ships/#{Ecto.UUID.generate()}/inventory")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/ships/:id/transit-logs" do
    test "returns transit logs", %{
      conn: conn,
      company: company,
      ship_type: ship_type,
      port: port,
      route: route
    } do
      ship =
        Factory.insert(:ship, company: company, ship_type: ship_type, port: port, name: "Ship 1")

      log = Factory.insert(:transit_log, ship: ship, route: route)

      conn = get(conn, ~p"/api/v1/ships/#{ship.id}/transit-logs")
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["id"] == log.id
    end

    test "returns 404 when ship not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/ships/#{Ecto.UUID.generate()}/transit-logs")
      assert json_response(conn, 404)
    end
  end

  describe "PATCH /api/v1/ships/:id" do
    test "renames a ship", %{conn: conn, company: company, ship_type: ship_type, port: port} do
      ship =
        Factory.insert(:ship,
          company: company,
          ship_type: ship_type,
          port: port,
          name: "Old Name"
        )

      conn = patch(conn, ~p"/api/v1/ships/#{ship.id}", %{name: "New Name"})
      assert %{"id" => id, "name" => "New Name"} = json_response(conn, 200)["data"]
      assert id == ship.id
    end

    test "returns 404 when ship not found", %{conn: conn} do
      conn = patch(conn, ~p"/api/v1/ships/#{Ecto.UUID.generate()}", %{name: "New Name"})
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/ships/:id/transit" do
    test "puts a ship in transit", %{
      conn: conn,
      company: company,
      ship_type: ship_type,
      port: port
    } do
      # Make sure the route starts at the port
      route = Factory.insert(:route, from: port, to: Factory.insert(:port))

      ship =
        Factory.insert(:ship,
          company: company,
          ship_type: ship_type,
          port: port,
          route: nil,
          status: :docked
        )

      conn = post(conn, ~p"/api/v1/ships/#{ship.id}/transit", %{route_id: route.id})

      assert %{"id" => id, "status" => "traveling", "route_id" => route_id} =
               json_response(conn, 200)["data"]

      assert id == ship.id
      assert route_id == route.id
    end

    test "returns 404 when ship not found", %{conn: conn, port: port} do
      route = Factory.insert(:route, from: port, to: Factory.insert(:port))
      conn = post(conn, ~p"/api/v1/ships/#{Ecto.UUID.generate()}/transit", %{route_id: route.id})
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/ships/:id/transfer-to-warehouse" do
    test "transfers cargo to warehouse", %{
      conn: conn,
      company: company,
      ship_type: ship_type,
      port: port,
      good: good
    } do
      ship =
        Factory.insert(:ship, company: company, ship_type: ship_type, port: port, status: :docked)

      Factory.insert(:ship_cargo, ship: ship, good: good, quantity: 100)

      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn =
        post(conn, ~p"/api/v1/ships/#{ship.id}/transfer-to-warehouse", %{
          warehouse_id: warehouse.id,
          good_id: good.id,
          quantity: 50
        })

      assert response(conn, 204)
    end

    test "returns 404 when ship not found", %{
      conn: conn,
      company: company,
      port: port,
      good: good
    } do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn =
        post(conn, ~p"/api/v1/ships/#{Ecto.UUID.generate()}/transfer-to-warehouse", %{
          warehouse_id: warehouse.id,
          good_id: good.id,
          quantity: 50
        })

      assert json_response(conn, 404)
    end
  end
end
