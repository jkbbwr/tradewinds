defmodule TradewindsWeb.AuthJSON do
  def player(%{player: player}) do
    %{data: data(player)}
  end

  def login(%{auth_token: auth_token}) do
    %{
      data: %{
        token: auth_token.token
      }
    }
  end

  def data(player) do
    %{
      id: player.id,
      name: player.name,
      email: player.email,
      discord_id: player.discord_id,
      enabled: player.enabled,
      inserted_at: player.inserted_at
    }
  end
end
