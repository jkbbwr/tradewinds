defmodule Tradewinds.AccountsTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Factory

  describe "players" do
    test "create_player/3 creates a player" do
      assert {:ok, player} = Accounts.create_player("Test User", "test@example.com", "password123")
      assert player.name == "Test User"
      assert player.email == "test@example.com"
    end

    test "create_player/3 with invalid data returns an error" do
      assert {:error, _} = Accounts.create_player("Test User", "invalid-email", "short")
    end

    test "fetch_player_by_id/1 returns a player" do
      player = Factory.insert(:player)
      assert {:ok, fetched_player} = Accounts.fetch_player_by_id(player.id)
      assert fetched_player.id == player.id
    end

    test "fetch_player_by_email/1 returns a player" do
      player = Factory.insert(:player)
      assert {:ok, fetched_player} = Accounts.fetch_player_by_email(player.email)
      assert fetched_player.email == player.email
    end

    test "enable_player/1 enables a player" do
      player = Factory.insert(:player, enabled: false)
      assert {:ok, updated_player} = Accounts.enable_player(player)
      assert updated_player.enabled
    end

    test "disable_player/1 disables a player" do
      player = Factory.insert(:player, enabled: true)
      assert {:ok, updated_player} = Accounts.disable_player(player)
      assert not updated_player.enabled
    end
  end

  describe "login_player/2" do
    test "logins a player with valid credentials" do
      player = Factory.insert(:player, password: "password123", enabled: true)
      assert {:ok, %{token: token}} = Accounts.login_player(player.email, "password123")
      assert is_binary(token)
    end

    test "returns error for invalid credentials" do
      player = Factory.insert(:player, password: "password123")
      assert {:error, :invalid_credentials} = Accounts.login_player(player.email, "wrong_password")
    end

    test "returns error for disabled player" do
      player = Factory.insert(:player, password: "password122", enabled: false)
      assert {:error, :player_not_enabled} = Accounts.login_player(player.email, "password123")
    end
  end
end
