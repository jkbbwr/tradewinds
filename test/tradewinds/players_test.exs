defmodule Tradewinds.PlayersTest do
  use Tradewinds.DataCase

  alias Tradewinds.Players

  describe "players" do
    test "register/3 creates a player with valid attributes" do
      assert {:ok, player} = Players.register("John Doe", "john@example.com", "password123")
      assert player.name == "John Doe"
      assert player.email == "john@example.com"
      assert player.password_hash
      refute player.enabled
    end

    test "register/3 fails with invalid email" do
      assert {:error, changeset} = Players.register("John Doe", "invalid-email", "password123")
      assert "has invalid format" in errors_on(changeset).email
    end

    test "register/3 fails with duplicate email" do
      insert(:player, email: "john@example.com")
      assert {:error, changeset} = Players.register("Jane Doe", "john@example.com", "password123")
      assert "has already been taken" in errors_on(changeset).email
    end

    test "register/3 fails with short password" do
      assert {:error, changeset} = Players.register("John Doe", "john@example.com", "short")
      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end

    test "fetch_player_by_email/1 returns player" do
      player = insert(:player, email: "findme@example.com")
      assert {:ok, fetched_player} = Players.fetch_player_by_email("findme@example.com")
      assert fetched_player.id == player.id
    end

    test "fetch_player_by_email/1 returns error when not found" do
      assert {:error, :email_not_found} = Players.fetch_player_by_email("unknown@example.com")
    end

    test "is_enabled?/1 checks enabled status" do
      enabled_player = insert(:player, enabled: true)
      disabled_player = insert(:player, enabled: false)

      assert :ok = Players.is_enabled?(enabled_player)
      assert {:error, :player_not_enabled} = Players.is_enabled?(disabled_player)
    end

    test "enable/1 enables the player" do
      player = insert(:player, enabled: false)
      assert {:ok, updated_player} = Players.enable(player)
      assert updated_player.enabled
    end

    test "disable/1 disables the player" do
      player = insert(:player, enabled: true)
      assert {:ok, updated_player} = Players.disable(player)
      refute updated_player.enabled
    end
  end
end
