defmodule Tradewinds.Accounts do
  @moduledoc """
  The Accounts context.
  Handles players, authentication, and user management.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Player
  alias Tradewinds.Schema.AuthToken
  alias Argon2

  def register_player(name, email, password) do
    %Player{}
    |> Player.registration_changeset(%{
      name: name,
      email: email,
      password: password
    })
    |> Repo.insert()
  end

  def login_player(email, password) do
    with {:ok, player} <- get_player_by_email(email),
         :ok <- verify_pass(player, password),
         :ok <- is_enabled(player) do
      create_auth_token(player)
    else
      {:error, :not_found} ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      error ->
        error
    end
  end

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

  def get_player_by_id(id) do
    Repo.fetch(Player, id)
  end

  def get_player_by_email(email) do
    Repo.fetch_by(Player, email: email)
  end

  def disable_player(player) do
    player
    |> Player.enabled_changeset(false)
    |> Repo.update()
  end

  def enable_player(player) do
    player
    |> Player.enabled_changeset(true)
    |> Repo.update()
  end

  def create_auth_token(player) do
    token_lifespan = 24 * 60 * 60

    Phoenix.Token.sign(TradewindsWeb.Endpoint, "user auth", player.id, max_age: token_lifespan)
    |> then(fn token -> %AuthToken{player_id: player.id, token: token} end)
    |> Repo.insert()
  end
end
