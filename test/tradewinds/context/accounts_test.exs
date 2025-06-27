defmodule Tradewinds.AccountsTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Accounts
  alias Tradewinds.Factory
  alias Tradewinds.Schema.Player

  describe "register_player/3" do
    test "creates a player with valid data" do
      user_attrs = Factory.build(:user)
      assert {:ok, %Player{} = player} = Accounts.register_player(user_attrs.name, user_attrs.email, user_attrs.password)
      assert player.name == user_attrs.name
      assert player.email == user_attrs.email
      assert player.enabled == false
    end

    test "returns an error with invalid data" do
      assert {:error, changeset} = Accounts.register_player("Test User", "invalid-email", "short")
      assert errors_on(changeset) == %{email: ["has invalid format"], password: ["should be at least 8 character(s)"]}
    end

    test "returns an error if email is already taken" do
      user = Factory.insert(:user)
      assert {:error, changeset} = Accounts.register_player("Another User", user.email, "password123")
      assert errors_on(changeset) == %{email: ["has already been taken"]}
    end
  end

  describe "login_player/2" do
    test "returns an auth token for a valid, enabled user" do
      user = Factory.insert(:user, enabled: true)
      assert {:ok, _token} = Accounts.login_player(user.email, user.password)
    end

    test "returns an error for an invalid password" do
      user = Factory.insert(:user, enabled: true)
      assert {:error, :invalid_credentials} = Accounts.login_player(user.email, "wrongpassword")
    end

    test "returns an error for a disabled user" do
      user = Factory.insert(:user, enabled: false)
      assert {:error, :player_not_enabled} = Accounts.login_player(user.email, user.password)
    end

    test "returns an error for a non-existent user" do
      assert {:error, :invalid_credentials} = Accounts.login_player("nosuchuser@example.com", "password")
    end
  end

  describe "player getters" do
    test "get_player_by_id/1 returns a player" do
      player = Factory.insert(:user)
      assert {:ok, %Player{}} = Accounts.get_player_by_id(player.id)
    end

    test "get_player_by_email/1 returns a player" do
      player = Factory.insert(:user)
      assert {:ok, %Player{}} = Accounts.get_player_by_email(player.email)
    end
  end

  describe "enable_player/1 and disable_player/1" do
    test "enables and disables a player" do
      player = Factory.insert(:user, enabled: false)
      assert {:ok, %Player{enabled: true}} = Accounts.enable_player(player)
      assert {:ok, %Player{enabled: false}} = Accounts.disable_player(player)
    end
  end
end
