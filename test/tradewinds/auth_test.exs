defmodule Tradewinds.AuthTest do
  use Tradewinds.DataCase

  alias Tradewinds.Auth

  describe "authentication" do
    test "authenticate/2 succeeds with correct credentials and enabled player" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)

      assert {:ok, auth_token} = Auth.authenticate(player.email, password)
      assert auth_token.player_id == player.id
      assert auth_token.token
    end

    test "authenticate/2 fails if player is disabled" do
      password = "password1234"
      player = insert(:player, password: password, enabled: false)

      assert {:error, :player_not_enabled} = Auth.authenticate(player.email, password)
    end

    test "authenticate/2 fails with wrong password" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)

      assert {:error, :unauthorized} = Auth.authenticate(player.email, "wrongpassword")
    end

    test "authenticate/2 fails with unknown email" do
      assert {:error, :email_not_found} = Auth.authenticate("unknown@example.com", "password")
    end
  end

  describe "token management" do
    test "validate/1 succeeds with valid token" do
      # We need a real token signed by the Endpoint
      password = "password1234"
      player = insert(:player, password: password, enabled: true)
      {:ok, created_token} = Auth.authenticate(player.email, password)

      assert {:ok, fetched_token} = Auth.validate(created_token.token)
      assert fetched_token.id == created_token.id
      assert fetched_token.player.id == player.id
    end

    test "validate/1 fails with invalid token string" do
      assert {:error, :invalid} = Auth.validate("invalid_token_string")
    end
    
    test "validate/1 fails if token exists but signature is invalid (tampered)" do 
        # Create a valid token entry in DB but use a tampered string for verification
        password = "password1234"
        player = insert(:player, password: password, enabled: true)
        {:ok, created_token} = Auth.authenticate(player.email, password)
        
        # Tamper the token
        tampered_token = created_token.token <> "tampered"
        
        # Should fail at Phoenix.Token.verify
        assert {:error, :invalid} = Auth.validate(tampered_token)
    end

    test "revoke/1 removes the token" do
      password = "password1234"
      player = insert(:player, password: password, enabled: true)
      {:ok, created_token} = Auth.authenticate(player.email, password)

      assert {1, _} = Auth.revoke(created_token.token)
      
      # Should fail to validate now because it's deleted from DB
      # Note: Phoenix.Token.verify will still pass if it hasn't expired, 
      # but fetch_auth_token will fail.
      
      # Let's verify exactly what validate returns
      # validate/1 -> Phoenix.Token.verify (ok) -> fetch_auth_token (fail)
      
      assert {:error, :unauthorized} = Auth.validate(created_token.token)
    end
  end
end
