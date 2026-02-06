defmodule Tradewinds.Auth do
  alias Tradewinds.Players
  alias Tradewinds.Auth.AuthToken
  alias Tradewinds.Repo
  import Ecto.Query

  def authenticate(email, password) do
    with {:ok, player} <- Players.fetch_player_by_email(email),
         :ok <- Players.is_enabled?(player),
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
         {:ok, auth_token} <- fetch_auth_token(token, player_id) do
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
