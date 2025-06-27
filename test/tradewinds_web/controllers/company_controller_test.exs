defmodule TradewindsWeb.CompanyControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Factory

  describe "POST /api/companies" do
    test "creates a company with valid data", %{conn: conn} do
      player = Factory.insert(:user)
      port = Factory.insert(:port)

      company_params = %{
        "name" => "The Black Pearl",
        "ticker" => "PEARL",
        "home_port_id" => port.id,
        "directors" => [player.id]
      }

      conn = post(conn, "/api/companies", %{"company" => company_params})

      assert conn.status == 201
      assert json_response(conn, 201)["company"]["name"] == "The Black Pearl"
    end
  end
end
