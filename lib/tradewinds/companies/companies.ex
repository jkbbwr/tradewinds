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
  def create(%Scope{} = scope, name, ticker, home_port_id, treasury \\ 10000) do
    Repo.transact(fn ->
      with changeset <-
             Company.create_changeset(%Company{}, %{
               name: name,
               ticker: ticker,
               home_port_id: home_port_id,
               treasury: treasury
             }),
           {:ok, company} <- Repo.insert(changeset),
           scope <- Scope.put_company_id(scope, company.id),
           {:ok, _director} <- add_director(scope, company) do
        {:ok, company}
      end
    end)
  end

  def add_director(%Scope{} = scope, %Company{} = company) do
    with :ok <- Scope.authorizes?(scope, company.id) do
      %Director{}
      |> Director.create_changeset(%{company_id: company.id, player_id: scope.player.id})
      |> Repo.insert()
    end
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
