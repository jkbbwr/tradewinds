defmodule Tradewinds.Accounts do
  @moduledoc """
  The Accounts context.
  Handles players, authentication, and user management.
  """

  alias Argon2
  alias Tradewinds.Repo
  alias Tradewinds.Accounts.AuthToken
  alias Tradewinds.Accounts.Player

  def fetch_player_by_id(id) do
    Repo.get(Player, id)
    |> Repo.ok_or("can't find player with id #{id}")
  end

  def fetch_player_by_email(email) do
    Repo.get_by(Player, email: email)
    |> Repo.ok_or("can't find player with email #{email}")
  end

  def enable_player(player) do
    player
    |> Player.enabled_changeset(true)
    |> Repo.update()
  end

  def disable_player(player) do
    player
    |> Player.enabled_changeset(false)
    |> Repo.update()
  end

  def create_player(name, email, password) do
    %Player{}
    |> Player.create_changeset(%{
      name: name,
      email: email,
      password: password
    })
    |> Repo.insert()
  end

  def create_auth_token(player, token) do
    %AuthToken{player_id: player.id, token: token}
    |> Repo.insert()
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

  def login_player(email, password) do
    with {:ok, player} <- fetch_player_by_email(email),
         :ok <- verify_pass(player, password),
         :ok <- is_enabled(player),
         token = generate_token(player) do
      create_auth_token(player, token)
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
