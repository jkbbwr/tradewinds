defmodule TradewindsWeb.PlayerJSON do
  def register(%{player: player}) do
    %{"player" => player(player)}
  end

  def login(%{token: token}) do
    %{"token" => token(token)}
  end

  def token(token) do
    %{
      id: token.id,
      token: token.token,
      inserted_at: token.inserted_at,
      updated_at: token.updated_at,
      player_id: token.player_id
    }
  end

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
