defmodule Tradewinds.AccountsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Accounts

  describe "players" do
    test "register/3 creates a player with valid attributes" do
      assert {:ok, player} = Accounts.register("John Doe", "john@example.com", "password123")
      assert player.name == "John Doe"
      assert player.email == "john@example.com"
      assert player.password_hash
      refute player.enabled
    end

    test "register/3 fails with invalid email" do
      assert {:error, changeset} = Accounts.register("John Doe", "invalid-email", "password123")
      assert "has invalid format" in errors_on(changeset).email
    end

    test "register/3 fails with duplicate email" do
      insert(:player, email: "john@example.com")
      assert {:error, changeset} = Accounts.register("Jane Doe", "john@example.com", "password123")
      assert "has already been taken" in errors_on(changeset).email
    end

    test "register/3 fails with short password" do
      assert {:error, changeset} = Accounts.register("John Doe", "john@example.com", "short")
      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end

    test "fetch_player_by_email/1 returns player" do
      player = insert(:player, email: "findme@example.com")
      assert {:ok, fetched_player} = Accounts.fetch_player_by_email("findme@example.com")
      assert fetched_player.id == player.id
    end

    test "fetch_player_by_email/1 returns error when not found" do
      assert {:error, :email_not_found} = Accounts.fetch_player_by_email("unknown@example.com")
    end

    test "is_enabled?/1 checks enabled status" do
      enabled_player = insert(:player, enabled: true)
      disabled_player = insert(:player, enabled: false)

      assert :ok = Accounts.is_enabled?(enabled_player)
      assert {:error, :player_not_enabled} = Accounts.is_enabled?(disabled_player)
    end

    test "enable/1 enables the player" do
      player = insert(:player, enabled: false)
      assert {:ok, updated_player} = Accounts.enable(player)
      assert updated_player.enabled
    end

    test "disable/1 disables the player" do
      player = insert(:player, enabled: true)
      assert {:ok, updated_player} = Accounts.disable(player)
      refute updated_player.enabled
    end
  end

  describe "authentication" do
    test "authenticate/2 succeeds with correct credentials and enabled player" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)

      assert {:ok, auth_token} = Accounts.authenticate(player.email, password)
      assert auth_token.player_id == player.id
      assert auth_token.token
    end

    test "authenticate/2 fails if player is disabled" do
      password = "password1234"
      player = insert(:player, password: password, enabled: false)

      assert {:error, :player_not_enabled} = Accounts.authenticate(player.email, password)
    end

    test "authenticate/2 fails with wrong password" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)

      assert {:error, :unauthorized} = Accounts.authenticate(player.email, "wrongpassword")
    end

    test "authenticate/2 fails with unknown email" do
      assert {:error, :email_not_found} = Accounts.authenticate("unknown@example.com", "password")
    end
  end

  describe "token management" do
    test "validate/1 succeeds with valid token" do
      # We need a real token signed by the Endpoint
      password = "password1234"
      player = insert(:player, password: password, enabled: true)
      {:ok, created_token} = Accounts.authenticate(player.email, password)

      assert {:ok, fetched_token} = Accounts.validate(created_token.token)
      assert fetched_token.id == created_token.id
      assert fetched_token.player.id == player.id
    end

    test "validate/1 fails with invalid token string" do
      assert {:error, :invalid} = Accounts.validate("invalid_token_string")
    end
    
    test "validate/1 fails if token exists but signature is invalid (tampered)" do 
        # Create a valid token entry in DB but use a tampered string for verification
        password = "password1234"
        player = insert(:player, password: password, enabled: true)
        {:ok, created_token} = Accounts.authenticate(player.email, password)
        
        # Tamper the token
        tampered_token = created_token.token <> "tampered"
        
        # Should fail at Phoenix.Token.verify
        assert {:error, :invalid} = Accounts.validate(tampered_token)
    end

    test "validate/1 fails if player is disabled after login" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)
      {:ok, created_token} = Accounts.authenticate(player.email, password)

      # Disable the player
      Accounts.disable(player)

      # Now validate should fail
      assert {:error, :player_not_enabled} = Accounts.validate(created_token.token)
    end

    test "revoke/1 removes the token" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)
      {:ok, created_token} = Accounts.authenticate(player.email, password)

      assert {1, _} = Accounts.revoke(created_token.token)
      
      # Should fail to validate now because it's deleted from DB
      # Note: Phoenix.Token.verify will still pass if it hasn't expired, 
      # but fetch_auth_token will fail.
      
      # Let's verify exactly what validate returns
      # validate/1 -> Phoenix.Token.verify (ok) -> fetch_auth_token (fail)
      
      assert {:error, :unauthorized} = Accounts.validate(created_token.token)
    end
  end
end
