defmodule TradewindsWeb.PlayerControllerTest do
  use TradewindsWeb.ConnCase, async: true

  alias Jason

  @valid_attrs %{name: "Test Player", email: "test@example.com", password: "password123"}
  @invalid_attrs %{name: "", email: "invalid-email", password: "short"}

  describe "register" do
    test "registers player with valid attributes", %{conn: conn} do
      conn = post(conn, ~p"/api/register", @valid_attrs)
      response = json_response(conn, 200)

      name = @valid_attrs.name
      email = @valid_attrs.email

      assert %{
               "id" => _id,
               "name" => ^name,
               "email" => ^email,
               "inserted_at" => _inserted_at,
               "updated_at" => _updated_at
             } = response["player"]
    end

    test "does not register player with invalid attributes", %{conn: conn} do
      conn = post(conn, ~p"/api/register", @invalid_attrs)

      assert json_response(conn, 400)["errors"] == %{
               "name" => ["can\'t be blank"],
               "email" => ["has invalid format"],
               "password" => ["has invalid format", "should be at least 8 character(s)"]
             }
    end

    test "does not register player with missing required attributes", %{conn: conn} do
      attrs_missing_name = Map.delete(@valid_attrs, :name)
      conn_missing_name = post(conn, ~p"/api/register", attrs_missing_name)
      assert json_response(conn_missing_name, 400)["errors"]["name"] == ["can't be blank"]

      attrs_missing_email = Map.delete(@valid_attrs, :email)

      conn_missing_email =
        post(conn, ~p"/api/register", attrs_missing_email)

      assert json_response(conn_missing_email, 400)["errors"]["email"] == ["can't be blank"]

      attrs_missing_password = Map.delete(@valid_attrs, :password)

      conn_missing_password =
        post(conn, ~p"/api/register", attrs_missing_password)

      assert json_response(conn_missing_password, 400)["errors"]["password"] == ["can't be blank"]
    end

    test "does not register player with non-unique email", %{conn: conn} do
      # Register the first player
      post(conn, ~p"/api/register", @valid_attrs)

      # Attempt to register again with same email
      conn = post(conn, ~p"/api/register", @valid_attrs)
      assert json_response(conn, 400)["errors"]["email"] == ["has already been taken"]
    end
  end
end
