defmodule TradewindsWeb.WarehouseControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Companies
  alias Tradewinds.Factory

  setup %{conn: conn} do
    {:ok, player} = Accounts.register("Director", "director@example.com", "password123")
    {:ok, player} = Accounts.enable(player)
    {:ok, auth_token} = Accounts.authenticate("director@example.com", "password123")

    port = Factory.insert(:port)
    good = Factory.insert(:good)
    ship_type = Factory.insert(:ship_type)

    scope = Tradewinds.Scope.for_player(player)
    {:ok, company} = Companies.create(scope, "Warehouse Co", "WHSE1", port.id)

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
      good: good,
      ship_type: ship_type,
      scope: %{scope | company_id: company.id}
    }
  end

  describe "GET /api/v1/warehouses" do
    test "returns empty list when company has no warehouses", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/warehouses")
      assert json_response(conn, 200)["data"] == []
    end

    test "returns list of warehouses", %{conn: conn, company: company, port: port} do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn = get(conn, ~p"/api/v1/warehouses")
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["id"] == warehouse.id
    end
  end

  describe "POST /api/v1/warehouses" do
    test "creates a new warehouse", %{conn: conn, port: port} do
      conn = post(conn, ~p"/api/v1/warehouses", %{port_id: port.id})
      assert %{"id" => id, "port_id" => port_id, "level" => 1} = json_response(conn, 201)["data"]
      assert port_id == port.id
      assert id
    end

    test "returns 422 for invalid parameters", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/warehouses", %{port_id: "not-a-uuid"})
      assert json_response(conn, 422)
    end
  end

  describe "GET /api/v1/warehouses/:id" do
    test "returns warehouse details", %{conn: conn, company: company, port: port} do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn = get(conn, ~p"/api/v1/warehouses/#{warehouse.id}")
      assert %{"id" => id, "level" => level} = json_response(conn, 200)["data"]
      assert id == warehouse.id
      assert level == warehouse.level
    end

    test "returns 404 when warehouse not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/warehouses/#{Ecto.UUID.generate()}")
      assert json_response(conn, 404)
    end
  end

  describe "GET /api/v1/warehouses/:id/inventory" do
    test "returns empty inventory when warehouse has no items", %{
      conn: conn,
      company: company,
      port: port
    } do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn = get(conn, ~p"/api/v1/warehouses/#{warehouse.id}/inventory")
      assert json_response(conn, 200)["data"] == []
    end

    test "returns list of inventory items", %{
      conn: conn,
      company: company,
      port: port,
      good: good
    } do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      inventory =
        Factory.insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 100)

      conn = get(conn, ~p"/api/v1/warehouses/#{warehouse.id}/inventory")
      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["id"] == inventory.id
      assert Enum.at(data, 0)["quantity"] == 100
    end

    test "returns 404 when warehouse not found", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/warehouses/#{Ecto.UUID.generate()}/inventory")
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/warehouses/:id/grow" do
    test "upgrades a warehouse", %{conn: conn, company: company, port: port} do
      warehouse =
        Factory.insert(:warehouse, company: company, port: port, level: 1, capacity: 1000)

      conn = post(conn, ~p"/api/v1/warehouses/#{warehouse.id}/grow")
      assert %{"id" => id, "level" => 2, "capacity" => 2000} = json_response(conn, 200)["data"]
      assert id == warehouse.id
    end

    test "returns 404 when warehouse not found", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/warehouses/#{Ecto.UUID.generate()}/grow")
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/warehouses/:id/shrink" do
    test "downgrades a warehouse", %{conn: conn, company: company, port: port} do
      warehouse =
        Factory.insert(:warehouse, company: company, port: port, level: 2, capacity: 2000)

      conn = post(conn, ~p"/api/v1/warehouses/#{warehouse.id}/shrink")
      assert %{"id" => id, "level" => 1, "capacity" => 1000} = json_response(conn, 200)["data"]
      assert id == warehouse.id
    end

    test "returns 404 when warehouse not found", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/warehouses/#{Ecto.UUID.generate()}/shrink")
      assert json_response(conn, 404)
    end
  end

  describe "POST /api/v1/warehouses/:id/transfer-to-ship" do
    test "transfers cargo to ship", %{
      conn: conn,
      company: company,
      port: port,
      good: good,
      ship_type: ship_type
    } do
      warehouse = Factory.insert(:warehouse, company: company, port: port)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 100)

      ship =
        Factory.insert(:ship, company: company, ship_type: ship_type, port: port, status: :docked)

      conn =
        post(conn, ~p"/api/v1/warehouses/#{warehouse.id}/transfer-to-ship", %{
          ship_id: ship.id,
          good_id: good.id,
          quantity: 50
        })

      assert response(conn, 204)
    end

    test "returns 404 when warehouse not found", %{
      conn: conn,
      company: company,
      port: port,
      good: good,
      ship_type: ship_type
    } do
      ship =
        Factory.insert(:ship, company: company, ship_type: ship_type, port: port, status: :docked)

      conn =
        post(conn, ~p"/api/v1/warehouses/#{Ecto.UUID.generate()}/transfer-to-ship", %{
          ship_id: ship.id,
          good_id: good.id,
          quantity: 50
        })

      assert json_response(conn, 404)
    end
  end

  describe "DELETE /api/v1/warehouses/:id" do
    test "deletes an empty warehouse", %{conn: conn, company: company, port: port} do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn = delete(conn, ~p"/api/v1/warehouses/#{warehouse.id}")
      assert response(conn, 204)

      # Verify it's gone
      conn = get(build_conn() |> put_req_header("authorization", Enum.at(get_req_header(conn, "authorization"), 0)) |> put_req_header("tradewinds-company-id", company.id), ~p"/api/v1/warehouses/#{warehouse.id}")
      assert json_response(conn, 404)
    end

    test "fails to delete a non-empty warehouse", %{conn: conn, company: company, port: port, good: good} do
      warehouse = Factory.insert(:warehouse, company: company, port: port)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, good: good, quantity: 100)

      conn = delete(conn, ~p"/api/v1/warehouses/#{warehouse.id}")
      assert response = json_response(conn, 422)
      assert response["errors"]["detail"] =~ "Warehouse not empty"
    end

    test "returns 404 when warehouse not found", %{conn: conn} do
      conn = delete(conn, ~p"/api/v1/warehouses/#{Ecto.UUID.generate()}")
      assert json_response(conn, 404)
    end
  end
end
