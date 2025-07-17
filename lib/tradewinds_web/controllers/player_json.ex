defmodule TradewindsWeb.PlayerJSON do
  @moduledoc """
  Renders player data as JSON.
  """

  @doc """
  Renders the response for a newly registered player.
  """
  def register(%{player: player}) do
    %{"player" => player(player)}
  end

  @doc """
  Renders the response for a successful login.
  """
  def login(%{token: token}) do
    %{"token" => token(token)}
  end

  @doc """
  Renders a single auth token.
  """
  def token(token) do
    %{
      id: token.id,
      token: token.token,
      inserted_at: token.inserted_at,
      updated_at: token.updated_at,
      player_id: token.player_id
    }
  end

  @doc """
  Renders a single player.
  """
  def player(player) do
    %{
      id: player.id,
      name: player.name,
      email: player.email,
      inserted_at: player.inserted_at,
      updated_at: player.updated_at,
      enabled: player.enabled
    }
  end
end
