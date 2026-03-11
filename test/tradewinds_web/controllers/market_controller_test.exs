defmodule TradewindsWeb.MarketControllerTest do
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

    scope = Tradewinds.Scope.for_player(player)
    {:ok, company} = Companies.create(scope, "Market Co", "MKT1", port.id)

    # Increase reputation for market
    {:ok, company} = Companies.update_reputation(company.id, 500)

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
      scope: %{scope | company_id: company.id}
    }
  end

  describe "POST /api/v1/market/orders" do
    test "creates an order successfully", %{conn: conn, port: port, good: good} do
      conn =
        post(conn, ~p"/api/v1/market/orders", %{
          port_id: port.id,
          good_id: good.id,
          side: "buy",
          price: 100,
          total: 50
        })

      assert %{"id" => id, "side" => "buy", "price" => 100, "total" => 50, "status" => "open"} =
               json_response(conn, 201)["data"]

      assert id
    end
  end

  describe "GET /api/v1/market/orders" do
    test "lists orders", %{conn: conn, company: company, port: port, good: good} do
      order =
        Factory.insert(:order,
          company: company,
          port: port,
          good: good,
          side: :sell,
          price: 50,
          total: 100,
          remaining: 100
        )

      conn =
        get(conn, ~p"/api/v1/market/orders", port_id: port.id, good_id: good.id, side: "sell")

      data = json_response(conn, 200)["data"]

      assert length(data) == 1
      assert Enum.at(data, 0)["id"] == order.id
    end
  end

  describe "GET /api/v1/market/blended-price" do
    test "calculates blended price", %{conn: conn, company: company, port: port, good: good} do
      Factory.insert(:order,
        company: company,
        port: port,
        good: good,
        side: :sell,
        price: 50,
        total: 100,
        remaining: 100
      )

      Factory.insert(:order,
        company: company,
        port: port,
        good: good,
        side: :sell,
        price: 60,
        total: 100,
        remaining: 100
      )

      conn =
        get(conn, ~p"/api/v1/market/blended-price",
          port_id: port.id,
          good_id: good.id,
          side: "sell",
          quantity: 150
        )

      assert %{"blended_price" => blended_price} = json_response(conn, 200)["data"]
      # (100 * 50 + 50 * 60) / 150 = (5000 + 3000) / 150 = 8000 / 150 = 53.333
      assert abs(blended_price - 53.333) < 0.01
    end
  end

  describe "DELETE /api/v1/market/orders/:id" do
    test "cancels an order", %{conn: conn, company: company, port: port, good: good} do
      order =
        Factory.insert(:order,
          company: company,
          port: port,
          good: good,
          side: :sell,
          price: 50,
          total: 100,
          remaining: 100
        )

      conn = delete(conn, ~p"/api/v1/market/orders/#{order.id}")
      assert response(conn, 204)
    end
  end

  describe "POST /api/v1/market/orders/:id/fill" do
    test "fills an order", %{conn: conn, company: company, port: port, good: good} do
      # Set up another company (the seller)
      seller_scope = Tradewinds.Scope.for_player(Factory.insert(:player))
      {:ok, seller_company} = Companies.create(seller_scope, "Seller Co", "SELL1", port.id)
      {:ok, _} = Companies.update_reputation(seller_company.id, 500)

      {:ok, _} =
        Tradewinds.Companies.record_transaction(
          seller_company.id,
          1_000_000,
          :market_trade,
          :market,
          Ecto.UUID.generate(),
          DateTime.utc_now()
        )

      # Seller warehouse with goods
      seller_wh = Factory.insert(:warehouse, company: seller_company, port: port)
      Factory.insert(:warehouse_inventory, warehouse: seller_wh, good: good, quantity: 100)

      # Buyer warehouse
      Factory.insert(:warehouse, company: company, port: port)

      # Seller creates order
      {:ok, order} =
        Tradewinds.Market.post_order(
          %{seller_scope | company_id: seller_company.id},
          port.id,
          good.id,
          :sell,
          100,
          50
        )

      conn = post(conn, ~p"/api/v1/market/orders/#{order.id}/fill", %{quantity: 20})

      assert %{"id" => id, "remaining" => 30} = json_response(conn, 200)["data"]
      assert id == order.id
    end
  end
end
