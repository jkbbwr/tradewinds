defmodule TradewindsWeb.AuthControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Repo
  alias Tradewinds.Accounts.Player

  @register_params %{
    "name" => "Kibb",
    "email" => "kibb@example.com",
    "password" => "password123"
  }

  describe "POST /api/v1/auth/register" do
    test "renders player when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", @register_params)

      assert %{"id" => _id, "name" => "Kibb", "email" => "kibb@example.com"} =
               json_response(conn, 201)["data"]

      assert Repo.get_by(Player, email: "kibb@example.com")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", %{})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when email is already taken", %{conn: conn} do
      {:ok, _player} = Accounts.register("Existing", "kibb@example.com", "password123")

      conn = post(conn, ~p"/api/v1/auth/register", @register_params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "POST /api/v1/auth/login" do
    setup do
      {:ok, player} = Accounts.register("Kibb", "kibb@example.com", "password123")
      {:ok, player} = Accounts.enable(player)
      %{player: player}
    end

    test "returns token for valid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => "kibb@example.com",
          "password" => "password123"
        })

      assert %{"token" => token} = json_response(conn, 200)["data"]
      assert is_binary(token)
    end

    test "returns 401 for invalid password", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => "kibb@example.com",
          "password" => "wrongpassword"
        })

      assert json_response(conn, 401)
    end

    test "returns 401 for non-existent email", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => "nobody@example.com",
          "password" => "password123"
        })

      assert json_response(conn, 401)
    end

    test "returns 403 if account is not enabled", %{conn: conn, player: player} do
      Accounts.disable(player)

      conn =
        post(conn, ~p"/api/v1/auth/login", %{
          "email" => "kibb@example.com",
          "password" => "password123"
        })

      assert json_response(conn, 403) == %{"errors" => %{"detail" => "Account is disabled"}}
    end
  end

  describe "POST /api/v1/auth/revoke" do
    setup %{conn: conn} do
      {:ok, player} = Accounts.register("Kibb", "kibb@example.com", "password123")
      {:ok, _player} = Accounts.enable(player)
      {:ok, auth_token} = Accounts.authenticate("kibb@example.com", "password123")
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token.token}")
      %{player: player, auth_token: auth_token, conn: conn}
    end

    test "revokes the token successfully", %{conn: conn, auth_token: auth_token} do
      conn = post(conn, ~p"/api/v1/auth/revoke")
      assert response(conn, 204)

      assert {:error, :unauthorized} = Accounts.validate(auth_token.token)
    end

    test "fails with no token", %{} do
      conn = Phoenix.ConnTest.build_conn() |> post(~p"/api/v1/auth/revoke")
      assert json_response(conn, 401)
    end
  end

  describe "GET /api/v1/me" do
    setup %{conn: conn} do
      {:ok, player} = Accounts.register("Kibb", "kibb@example.com", "password123")
      {:ok, _player} = Accounts.enable(player)
      {:ok, auth_token} = Accounts.authenticate("kibb@example.com", "password123")
      conn = put_req_header(conn, "authorization", "Bearer #{auth_token.token}")
      %{player: player, auth_token: auth_token, conn: conn}
    end

    test "returns the authenticated player", %{conn: conn, player: player} do
      conn = get(conn, ~p"/api/v1/me")
      assert %{"id" => id, "name" => "Kibb"} = json_response(conn, 200)["data"]
      assert id == player.id
    end

    test "fails with no token", %{} do
      conn = Phoenix.ConnTest.build_conn() |> get(~p"/api/v1/me")
      assert json_response(conn, 401)
    end
  end
end
