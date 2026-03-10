defmodule TradewindsWeb.CompanyControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Companies
  alias Tradewinds.World

  setup %{conn: conn} do
    {:ok, player} = Accounts.register("Director", "director@example.com", "password123")
    {:ok, player} = Accounts.enable(player)
    {:ok, auth_token} = Accounts.authenticate("director@example.com", "password123")

    conn = put_req_header(conn, "authorization", "Bearer #{auth_token.token}")

    %{player: player, auth_token: auth_token, conn: conn}
  end

  describe "GET /api/v1/me/companies" do
    test "returns empty list when player has no companies", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/me/companies")
      assert json_response(conn, 200)["data"] == []
    end

    test "returns list of companies where player is a director", %{conn: conn, player: player} do
      port = Enum.at(World.list_ports().entries, 0)

      scope = Tradewinds.Scope.for_player(player)
      {:ok, _c1} = Companies.create(scope, "Company 1", "CMP1", port.id)
      {:ok, _c2} = Companies.create(scope, "Company 2", "CMP2", port.id)

      conn = get(conn, ~p"/api/v1/me/companies")
      data = json_response(conn, 200)["data"]

      assert length(data) == 2
      assert Enum.any?(data, fn c -> c["name"] == "Company 1" and c["ticker"] == "CMP1" end)
      assert Enum.any?(data, fn c -> c["name"] == "Company 2" and c["ticker"] == "CMP2" end)
    end

    test "fails with 401 if unauthorized" do
      conn = Phoenix.ConnTest.build_conn() |> get(~p"/api/v1/me/companies")
      assert json_response(conn, 401)
    end
  end

  describe "POST /api/v1/companies" do
    test "creates a new company successfully", %{conn: conn} do
      port = Enum.at(World.list_ports().entries, 0)

      conn =
        post(conn, ~p"/api/v1/companies", %{
          "name" => "New Traders",
          "ticker" => "TRD1",
          "home_port_id" => port.id
        })

      assert %{"id" => id, "name" => "New Traders"} = json_response(conn, 201)["data"]
      assert id
    end

    test "fails with validation error if ticker is too long", %{conn: conn} do
      port = Enum.at(World.list_ports().entries, 0)

      conn =
        post(conn, ~p"/api/v1/companies", %{
          "name" => "Invalid Ticker",
          "ticker" => "TOOLONG",
          "home_port_id" => port.id
        })

      assert json_response(conn, 422)["errors"]
    end
  end

  describe "GET /api/v1/company" do
    setup %{conn: conn, player: player} do
      port = Enum.at(World.list_ports().entries, 0)
      scope = Tradewinds.Scope.for_player(player)
      {:ok, company} = Companies.create(scope, "Test Company", "TEST1", port.id)

      conn = put_req_header(conn, "tradewinds-company-id", company.id)
      %{company: company, conn: conn}
    end

    test "returns company details", %{conn: conn, company: company} do
      conn = get(conn, ~p"/api/v1/company")
      assert %{"id" => id, "name" => "Test Company"} = json_response(conn, 200)["data"]
      assert id == company.id
    end

    test "fails if missing header", %{conn: conn} do
      conn = delete_req_header(conn, "tradewinds-company-id")
      conn = get(conn, ~p"/api/v1/company")
      assert json_response(conn, 400)["error"]
    end

    test "fails if not a director", %{company: company} do
      # New player not related to company
      {:ok, p2} = Accounts.register("Other", "other@example.com", "password123")
      {:ok, _p2} = Accounts.enable(p2)
      {:ok, t2} = Accounts.authenticate("other@example.com", "password123")

      conn2 =
        Phoenix.ConnTest.build_conn()
        |> put_req_header("authorization", "Bearer #{t2.token}")
        |> put_req_header("tradewinds-company-id", company.id)

      conn2 = get(conn2, ~p"/api/v1/company")
      assert json_response(conn2, 403)["error"]
    end
  end

  describe "GET /api/v1/company/economy" do
    setup %{conn: conn, player: player} do
      port = Enum.at(World.list_ports().entries, 0)
      scope = Tradewinds.Scope.for_player(player)
      {:ok, company} = Companies.create(scope, "Economy Co", "ECON1", port.id)

      conn = put_req_header(conn, "tradewinds-company-id", company.id)
      %{company: company, conn: conn}
    end

    test "returns economy summary", %{conn: conn, company: company} do
      conn = get(conn, ~p"/api/v1/company/economy")

      assert %{
               "treasury" => treasury,
               "reputation" => 1000,
               "ship_upkeep" => 0,
               "warehouse_upkeep" => 0,
               "total_upkeep" => 0
             } = json_response(conn, 200)["data"]

      assert treasury == company.treasury
    end
  end

  describe "GET /api/v1/company/ledger" do
    setup %{conn: conn, player: player} do
      port = Enum.at(World.list_ports().entries, 0)
      scope = Tradewinds.Scope.for_player(player)
      {:ok, company} = Companies.create(scope, "Ledger Co", "LEDG1", port.id)

      # Record a transaction so the ledger isn't empty
      {:ok, _company} =
        Companies.record_transaction(
          company.id,
          500,
          :market_trade,
          :market,
          Ecto.UUID.generate(),
          DateTime.utc_now()
        )

      conn = put_req_header(conn, "tradewinds-company-id", company.id)
      %{company: company, conn: conn}
    end

    test "returns ledger entries", %{conn: conn, company: company} do
      conn = get(conn, ~p"/api/v1/company/ledger")

      data = json_response(conn, 200)["data"]
      assert length(data) > 0

      entry = hd(data)
      assert entry["amount"] == 500
      assert entry["reason"] == "market_trade"
      assert entry["company_id"] == company.id
      assert entry["reference_type"] == "market"
    end
  end
end
