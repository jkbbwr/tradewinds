defmodule Tradewinds.Accounts do
  @moduledoc """
  The Accounts context.
  Handles player registration, authentication, and session management.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Accounts.Player
  alias Tradewinds.Accounts.AuthToken
  alias Tradewinds.Accounts.BannedIP

  ## Players

  @doc """
  Registers a new player with the given name, email, and password.
  Returns `{:ok, player}` or `{:error, changeset}`.
  """
  def register(name, email, password, discord_id \\ nil) do
    %Player{}
    |> Player.create_changeset(%{
      name: name,
      email: email,
      password: password,
      discord_id: discord_id
    })
    |> Repo.insert()
  end

  @doc """
  Retrieves a player by their email address.
  Returns `{:ok, player}` or `{:error, :email_not_found}`.
  """
  def fetch_player_by_email(email) do
    Repo.get_by(Player, email: email)
    |> Repo.ok_or(:email_not_found)
  end

  @doc """
  Checks if a player account is currently enabled.
  Returns `:ok` or `{:error, :player_not_enabled}`.
  """
  def is_enabled?(player) do
    if player.enabled, do: :ok, else: {:error, :player_not_enabled}
  end

  @doc """
  Enables a player account.
  """
  def enable(player) do
    player
    |> Player.enabled_changeset(true)
    |> Repo.update()
  end

  @doc """
  Disables a player account.
  """
  def disable(player) do
    player
    |> Player.enabled_changeset(false)
    |> Repo.update()
  end

  ## Authentication

  @doc """
  Authenticates a player by email and password.
  If successful, generates and returns a signed authentication token.
  Returns `{:ok, auth_token}` or `{:error, reason}`.
  """
  def authenticate(email, password) do
    with {:ok, player} <- fetch_player_by_email(email),
         :ok <- is_enabled?(player),
         :ok <- verify_pass(player, password) do
      token = generate_token(player)
      insert_token(token, player)
    end
  end

  @doc """
  Revokes an active authentication token.
  """
  def revoke(token) do
    AuthToken
    |> where(token: ^token)
    |> Repo.delete_all()
  end

  @doc """
  Validates a signed token, ensuring it belongs to an enabled player.
  Returns `{:ok, auth_token}` with preloaded player, or `{:error, reason}`.
  """
  def validate(token) do
    with {:ok, player_id} <- Phoenix.Token.verify(TradewindsWeb.Endpoint, "player auth", token),
         {:ok, auth_token} <- fetch_auth_token(token, player_id),
         :ok <- is_enabled?(auth_token.player) do
      {:ok, auth_token}
    end
  end

  @doc """
  Fetches an auth token from the database by the token string and player ID.
  """
  def fetch_auth_token(token, player_id) do
    Repo.get_by(AuthToken, token: token, player_id: player_id)
    |> Repo.preload(:player)
    |> Repo.ok_or(:unauthorized)
  end

  # Persists a newly generated authentication token to the database.
  defp insert_token(token, player) do
    %AuthToken{}
    |> AuthToken.create_changeset(%{player_id: player.id, token: token})
    |> Repo.insert()
  end

  # Dummy verification for missing players to prevent timing attacks.
  defp verify_pass(nil, _password) do
    if Argon2.no_user_verify() do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  # Verifies the provided plaintext password against the stored Argon2 hash.
  defp verify_pass(player, password) do
    if Argon2.verify_pass(password, player.password_hash) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Generates a signed Phoenix Token for the player, valid for 24 hours.
  """
  def generate_token(player) do
    Phoenix.Token.sign(TradewindsWeb.Endpoint, "player auth", player.id, max_age: 24 * 60 * 60)
  end

  ## IP Banning

  @doc """
  Bans an IP address.
  """
  def ban_ip(ip_address, reason \\ nil) do
    %BannedIP{}
    |> BannedIP.changeset(%{ip_address: to_string(ip_address), reason: reason})
    |> Repo.insert()
  end

  @doc """
  Checks if an IP address is banned.
  """
  def is_ip_banned?(ip_address) do
    ip = to_string(ip_address)

    {_cache_status, banned?} =
      Cachex.fetch(:tradewinds_cache, "banned_ip:#{ip}", fn _key ->
        exists? = Repo.exists?(from(b in BannedIP, where: b.ip_address == ^ip))
        {:commit, exists?}
      end)

    banned?
  end
end
