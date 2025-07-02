defmodule Tradewinds.AccountsRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.AuthToken
  alias Tradewinds.Schema.Player

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
end
