defmodule Tradewinds.Players do
  alias Tradewinds.Players.Player
  alias Tradewinds.Repo

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
end
