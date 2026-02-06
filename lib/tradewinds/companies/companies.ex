defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo

  @doc """
  Returns a list of company_ids that the player is a director of.
  """
  def list_player_company_ids(%Tradewinds.Players.Player{} = player) do
    player
    |> Ecto.assoc(:directorships)
    |> select([d], d.company_id)
    |> Repo.all()
  end
end
