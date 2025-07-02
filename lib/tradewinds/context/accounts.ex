defmodule Tradewinds.Accounts do
  @moduledoc """
  The Accounts context.
  Handles players, authentication, and user management.
  """

  alias Tradewinds.AccountsRepo
  alias Argon2

  defp verify_pass(player, password) do
    if Argon2.verify_pass(password, player.password_hash) do
      :ok
    else
      {:error, :invalid_credentials}
    end
  end

  defp is_enabled(player) do
    if player.enabled, do: :ok, else: {:error, :player_not_enabled}
  end

  def login_player(email, password) do
    with {:ok, player} <- AccountsRepo.fetch_player_by_email(email),
         :ok <- verify_pass(player, password),
         :ok <- is_enabled(player),
         token = generate_token(player) do
      AccountsRepo.create_auth_token(player, token)
    else
      {:error, {:not_found, _}} ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      error ->
        error
    end
  end

  def generate_token(player) do
    token_lifespan = 24 * 60 * 60
    Phoenix.Token.sign(TradewindsWeb.Endpoint, "user auth", player.id, max_age: token_lifespan)
  end
end
