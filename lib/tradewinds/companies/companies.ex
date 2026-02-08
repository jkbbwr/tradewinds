defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Scope
  alias Tradewinds.Companies.Company
  alias Tradewinds.Companies.Director
  alias Tradewinds.Accounts.Player

  @doc """
  Creates a company and assigns the current player (from scope) as a director.
  """
  def create(%Scope{player: player}, attrs) do
    Repo.transact(fn ->
      with {:ok, company} <- Repo.insert(Company.create_changeset(%Company{}, attrs)),
           {:ok, _director} <- add_director(company, player) do
        {:ok, company}
      end
    end)
  end

  @doc """
  Adds a new director to a company. (Scoped)
  Requires the actor (scope) to be an existing director of the company.
  """
  def add_director(%Scope{} = scope, %Company{} = company) do
    %Director{}
    |> Director.changeset(%{company_id: company.id, player_id: scope.player.id})
    |> Repo.insert()
  end

  @doc """
  Returns a list of company_ids that the player is a director of.
  """
  def list_player_company_ids(%Player{} = player) do
    player
    |> Ecto.assoc(:directorships)
    |> select([d], d.company_id)
    |> Repo.all()
  end
end
