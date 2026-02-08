defmodule Tradewinds.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Accounts.Player
  alias Tradewinds.Accounts.AuthToken

  ## Players

  def register(name, email, password) do
    %Player{}
    |> Player.create_changeset(%{
      name: name,
      email: email,
      password: password
    })
    |> Repo.insert()
  end

  def fetch_player_by_email(email) do
    Repo.get_by(Player, email: email)
    |> Repo.ok_or(:email_not_found)
  end

  def is_enabled?(player) do
    if player.enabled, do: :ok, else: {:error, :player_not_enabled}
  end

  def enable(player) do
    player
    |> Player.enabled_changeset(true)
    |> Repo.update()
  end

  def disable(player) do
    player
    |> Player.enabled_changeset(false)
    |> Repo.update()
  end

  ## Authentication

  def authenticate(email, password) do
    with {:ok, player} <- fetch_player_by_email(email),
         :ok <- is_enabled?(player),
         :ok <- verify_pass(player, password) do
      token = generate_token(player)
      insert_token(token, player)
    end
  end

  def revoke(token) do
    AuthToken
    |> where(token: ^token)
    |> Repo.delete_all()
  end

  def validate(token) do
    with {:ok, player_id} <- Phoenix.Token.verify(TradewindsWeb.Endpoint, "player auth", token),
         {:ok, auth_token} <- fetch_auth_token(token, player_id),
         :ok <- is_enabled?(auth_token.player) do
      {:ok, auth_token}
    end
  end

  def fetch_auth_token(token, player_id) do
    Repo.get_by(AuthToken, token: token, player_id: player_id)
    |> Repo.preload(:player)
    |> Repo.ok_or(:unauthorized)
  end

  defp insert_token(token, player) do
    %AuthToken{}
    |> AuthToken.create_changeset(%{player_id: player.id, token: token})
    |> Repo.insert()
  end

  defp verify_pass(nil, _password) do
    if Argon2.no_user_verify() do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  defp verify_pass(player, password) do
    if Argon2.verify_pass(password, player.password_hash) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  def generate_token(player) do
    Phoenix.Token.sign(TradewindsWeb.Endpoint, "player auth", player.id, max_age: 24 * 60 * 60)
  end
end
