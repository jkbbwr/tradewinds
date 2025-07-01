defmodule Tradewinds.AccountsRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.Player

  def fetch_player_by_id(id) do
    Repo.fetch(Player, id)
  end

  def fetch_player_by_email(email) do
    Repo.fetch_by(Player, email: email)
  end
end
