defmodule TradewindsWeb.PassengerControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Repo
  alias Tradewinds.Factory
  alias Tradewinds.Passengers.Passenger

  setup %{conn: conn} do
    {:ok, player} = Accounts.register("Director", "director@example.com", "password123")
    {:ok, player} = Accounts.enable(player)
    {:ok, auth_token} = Accounts.authenticate("director@example.com", "password123")

    port = Factory.insert(:port)
    company = Factory.insert(:company, home_port: port)
    insert(:director, company: company, player: player)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{auth_token.token}")
      |> put_req_header("tradewinds-company-id", company.id)

    {:ok, conn: conn, player: player, company: company, port: port}
  end

  defp insert(factory_name, attrs \\ %{}) do
    Factory.insert(factory_name, attrs)
  end

  describe "index" do
    test "lists all passengers with pagination", %{conn: conn} do
      insert(:passenger)
      insert(:passenger)

      conn = get(conn, ~p"/api/v1/passengers")
      assert %{"data" => passengers, "metadata" => metadata} = json_response(conn, 200)
      assert length(passengers) == 2
      assert Map.has_key?(metadata, "after")
    end

    test "filters passengers by status", %{conn: conn} do
      insert(:passenger, status: :available)
      insert(:passenger, status: :boarded)

      conn = get(conn, ~p"/api/v1/passengers", %{status: "available"})
      assert %{"data" => passengers} = json_response(conn, 200)
      assert length(passengers) == 1
      assert Enum.all?(passengers, fn p -> p["status"] == "available" end)
    end
  end

  describe "show" do
    test "shows a passenger", %{conn: conn} do
      passenger = insert(:passenger)

      conn = get(conn, ~p"/api/v1/passengers/#{passenger.id}")
      assert %{"data" => data} = json_response(conn, 200)
      assert data["id"] == passenger.id
    end

    test "returns 404 for non-existent passenger", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/passengers/#{Ecto.UUID.generate()}")
      assert json_response(conn, 404)
    end
  end

  describe "board" do
    test "boards a passenger group onto a ship", %{conn: conn, company: company, port: port} do
      ship_type = insert(:ship_type, passengers: 20)
      ship = insert(:ship, company: company, port: port, ship_type: ship_type, status: :docked)
      passenger = insert(:passenger, origin_port: port, count: 10, status: :available)

      conn = post(conn, ~p"/api/v1/passengers/#{passenger.id}/board", %{ship_id: ship.id})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["status"] == "boarded"
      assert data["ship_id"] == ship.id

      # Verify in DB
      updated_passenger = Repo.get!(Passenger, passenger.id)
      assert updated_passenger.status == :boarded
      assert updated_passenger.ship_id == ship.id
    end

    test "returns error if boarding fails (e.g. wrong port)", %{conn: conn, company: company} do
      port1 = insert(:port)
      port2 = insert(:port)
      ship = insert(:ship, company: company, port: port1, status: :docked)
      passenger = insert(:passenger, origin_port: port2, status: :available)

      conn = post(conn, ~p"/api/v1/passengers/#{passenger.id}/board", %{ship_id: ship.id})

      assert %{"errors" => %{"detail" => "Wrong port"}} = json_response(conn, 422)
    end
  end
end
