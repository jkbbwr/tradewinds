defmodule Tradewinds.Repo.PlayerRepo do
  alias Tradewinds.Schema.Player
  alias Tradewinds.Repo

  def register(name, email, password) do
    %Player{}
    |> Player.registration_changeset(%{name: name, email: email, password: password})
    |> Repo.insert()
  end

  def find_by_email(email) do
    Repo.fetch_by(Player, email: email)
  end
end
