defmodule TradewindsWeb.PlayerJSON do
  def register(%{player: player}) do
    %{"player" => player(player)}
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
