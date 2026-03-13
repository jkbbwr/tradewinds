defmodule TradewindsWeb.TradeControllerTest do
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

    # Needs a country, country has ports...
    # Factory handles it, but let's make sure good has a base_price
    # good.base_price should be > 0

    scope = Tradewinds.Scope.for_player(player)
    {:ok, company} = Companies.create(scope, "Trade Co", "TRD1", port.id)

    {:ok, _} =
      Tradewinds.Companies.record_transaction(
        company.id,
        10_000,
        :market_trade,
        :market,
        Ecto.UUID.generate(),
        DateTime.utc_now()
      )

    trader = Factory.insert(:trader)

    position =
      Factory.insert(:trader_position,
        trader: trader,
        port: port,
        good: good,
        stock: 100,
        target_stock: 100,
        spread: 0.1
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
      trader: trader,
      position: position,
      scope: %{scope | company_id: company.id}
    }
  end

  describe "GET /api/v1/trade/trader-positions" do
    test "lists trader positions for a trader", %{conn: conn, trader: trader, position: position} do
      conn = get(conn, ~p"/api/v1/trade/trader-positions", trader_id: trader.id)
      data = json_response(conn, 200)["data"]
      assert length(data) == 1
      assert Enum.at(data, 0)["id"] == position.id
    end
  end

  describe "POST /api/v1/trade/quote" do
    test "generates a quote", %{conn: conn, port: port, good: good} do
      conn =
        post(conn, ~p"/api/v1/trade/quote", %{
          port_id: port.id,
          good_id: good.id,
          action: "buy",
          quantity: 10
        })

      data = json_response(conn, 200)["data"]
      assert Map.has_key?(data, "token")
      assert data["quote"]["quantity"] == 10
      assert data["quote"]["action"] == "buy"
    end

    test "fails to generate a quote when not at port", %{conn: conn, good: good} do
      other_port = Factory.insert(:port)

      conn =
        post(conn, ~p"/api/v1/trade/quote", %{
          port_id: other_port.id,
          good_id: good.id,
          action: "buy",
          quantity: 10
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "POST /api/v1/trade/quotes/execute" do
    test "executes a quote", %{conn: conn, company: company, port: port, good: good} do
      # Need a ship or warehouse to deliver to
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      # 1. Generate Quote
      conn_quote =
        post(conn, ~p"/api/v1/trade/quote", %{
          port_id: port.id,
          good_id: good.id,
          action: "buy",
          quantity: 10
        })

      data = json_response(conn_quote, 200)["data"]
      token = data["token"]

      # 2. Execute Quote
      conn_exec =
        post(conn, ~p"/api/v1/trade/quotes/execute", %{
          token: token,
          destinations: [
            %{type: "warehouse", id: warehouse.id, quantity: 10}
          ]
        })

      assert json_response(conn_exec, 200)["data"]["action"] == "buy"
    end
  end

  describe "POST /api/v1/trade/quotes/batch" do
    test "generates multiple quotes", %{conn: conn, port: port, good: good} do
      conn =
        post(conn, ~p"/api/v1/trade/quotes/batch", %{
          requests: [
            %{
              port_id: port.id,
              good_id: good.id,
              action: "buy",
              quantity: 5
            },
            %{
              port_id: port.id,
              good_id: good.id,
              action: "buy",
              quantity: 10
            }
          ]
        })

      data = json_response(conn, 200)["data"]
      assert length(data) == 2
      assert Enum.at(data, 0)["status"] == "success"
      assert Enum.at(data, 0)["quote"]["quantity"] == 5
      assert Enum.at(data, 1)["status"] == "success"
      assert Enum.at(data, 1)["quote"]["quantity"] == 10
    end
  end

  describe "POST /api/v1/trade/quotes/execute/batch" do
    test "executes multiple quotes", %{conn: conn, company: company, port: port, good: good} do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      # 1. Generate Batch Quotes
      conn_batch_quote =
        post(conn, ~p"/api/v1/trade/quotes/batch", %{
          requests: [
            %{port_id: port.id, good_id: good.id, action: "buy", quantity: 5},
            %{port_id: port.id, good_id: good.id, action: "buy", quantity: 10}
          ]
        })

      batch_data = json_response(conn_batch_quote, 200)["data"]
      token1 = Enum.at(batch_data, 0)["token"]
      token2 = Enum.at(batch_data, 1)["token"]

      # 2. Execute Batch Quotes
      conn_batch_exec =
        post(conn, ~p"/api/v1/trade/quotes/execute/batch", %{
          requests: [
            %{
              token: token1,
              destinations: [%{type: "warehouse", id: warehouse.id, quantity: 5}]
            },
            %{
              token: token2,
              destinations: [%{type: "warehouse", id: warehouse.id, quantity: 10}]
            }
          ]
        })

      data = json_response(conn_batch_exec, 200)["data"]
      assert length(data) == 2
      assert Enum.at(data, 0)["status"] == "success"
      assert Enum.at(data, 0)["execution"]["quantity"] == 5
      assert Enum.at(data, 1)["status"] == "success"
      assert Enum.at(data, 1)["execution"]["quantity"] == 10
    end
  end

  describe "POST /api/v1/trade/execute" do
    test "executes an immediate trade", %{conn: conn, company: company, port: port, good: good} do
      warehouse = Factory.insert(:warehouse, company: company, port: port)

      conn =
        post(conn, ~p"/api/v1/trade/execute", %{
          port_id: port.id,
          good_id: good.id,
          action: "buy",
          destinations: [
            %{type: "warehouse", id: warehouse.id, quantity: 10}
          ]
        })

      assert json_response(conn, 200)["data"]["action"] == "buy"
    end
  end
end
