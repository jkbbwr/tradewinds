defmodule TradewindsWeb.ShipyardControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Companies
  alias Tradewinds.Factory
  alias Tradewinds.Shipyards

  setup %{conn: conn} do
    {:ok, player} = Accounts.register("Director", "director@example.com", "password123")
    {:ok, player} = Accounts.enable(player)
    {:ok, auth_token} = Accounts.authenticate("director@example.com", "password123")

    port = Factory.insert(:port)
    shipyard = Factory.insert(:shipyard, port: port)

    scope = Tradewinds.Scope.for_player(player)
    {:ok, company} = Companies.create(scope, "Ship Co", "SHIP1", port.id)

    # give the company some money
    {:ok, _} =
      Tradewinds.Companies.record_transaction(
        company.id,
        1_000_000,
        :market_trade,
        :market,
        Ecto.UUID.generate(),
        DateTime.utc_now()
      )

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{auth_token.token}")
      |> put_req_header("tradewinds-company-id", company.id)

    %{
      conn: conn,
      company: company,
      player: player,
      port: port,
      shipyard: shipyard,
      scope: %{scope | company_id: company.id}
    }
  end

  describe "GET /api/v1/world/ports/:port_id/shipyard" do
    test "returns shipyard for port", %{conn: conn, port: port, shipyard: shipyard} do
      conn = get(conn, ~p"/api/v1/world/ports/#{port.id}/shipyard")
      assert %{"id" => id, "port_id" => port_id} = json_response(conn, 200)["data"]
      assert id == shipyard.id
      assert port_id == port.id
    end

    test "returns 404 when port not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/world/ports/#{Ecto.UUID.generate()}/shipyard")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/shipyards/:shipyard_id/inventory" do
    test "returns inventory for shipyard", %{conn: conn, shipyard: shipyard, port: port} do
      ship_type = Factory.insert(:ship_type, base_price: 1000)

      ship =
        Factory.insert(:ship, status: :docked, company_id: nil, port: port, ship_type: ship_type)

      {:ok, _} = Shipyards.create_ship(shipyard.id, ship_type.id, ship.id, 1000)

      conn = get(conn, ~p"/api/v1/shipyards/#{shipyard.id}/inventory")
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["shipyard_id"] == shipyard.id
      assert Enum.at(data, 0)["ship_type_id"] == ship_type.id
      assert Enum.at(data, 0)["cost"] == 1000
    end

    test "returns 404 when shipyard not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/shipyards/#{Ecto.UUID.generate()}/inventory")
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/shipyards/:shipyard_id/purchase" do
    test "purchases a ship successfully", %{conn: conn, shipyard: shipyard, port: port} do
      ship_type = Factory.insert(:ship_type, base_price: 1000)

      ship =
        Factory.insert(:ship, status: :docked, company_id: nil, port: port, ship_type: ship_type)

      {:ok, _} = Shipyards.create_ship(shipyard.id, ship_type.id, ship.id, 1000)

      conn =
        post(conn, ~p"/api/v1/shipyards/#{shipyard.id}/purchase", %{ship_type_id: ship_type.id})

      assert %{"id" => id, "ship_type_id" => st_id} = json_response(conn, 200)["data"]
      assert id == ship.id
      assert st_id == ship_type.id
    end

    test "returns 404 when shipyard not found", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/shipyards/#{Ecto.UUID.generate()}/purchase", %{
          ship_type_id: Ecto.UUID.generate()
        })

      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/shipyards/:shipyard_id/sell-quote" do
    test "returns quote for ship_type_id", %{conn: conn, shipyard: shipyard} do
      ship_type = Factory.insert(:ship_type, base_price: 1000)

      conn =
        get(conn, ~p"/api/v1/shipyards/#{shipyard.id}/sell-quote", %{
          ship_type_id: ship_type.id
        })

      # 0 stock -> 90% = 900
      assert json_response(conn, 200)["data"]["price"] == 900
    end

    test "returns quote for ship_id", %{conn: conn, shipyard: shipyard} do
      ship_type = Factory.insert(:ship_type, base_price: 1000)
      ship = Factory.insert(:ship, ship_type: ship_type)

      conn =
        get(conn, ~p"/api/v1/shipyards/#{shipyard.id}/sell-quote", %{
          ship_id: ship.id
        })

      # 0 stock -> 90% = 900
      assert json_response(conn, 200)["data"]["price"] == 900
    end

    test "returns 404 when ship not found", %{conn: conn, shipyard: shipyard} do
      conn =
        get(conn, ~p"/api/v1/shipyards/#{shipyard.id}/sell-quote", %{
          ship_id: Ecto.UUID.generate()
        })

      assert json_response(conn, 404)
    end

    test "returns 422 when both ship_id and ship_type_id are missing", %{conn: conn, shipyard: shipyard} do
      conn = get(conn, ~p"/api/v1/shipyards/#{shipyard.id}/sell-quote")

      assert json_response(conn, 422)
    end
  end
end
