defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Scope
  alias Tradewinds.Companies.Company
  alias Tradewinds.Companies.Director
  alias Tradewinds.Companies.Ledger
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

  def record_transaction(
        company_id,
        amount,
        reason,
        ref_type,
        ref_id,
        tick,
        opts \\ []
      ) do
    idempotency_key = Keyword.get_lazy(opts, :idempotency_key, &Ecto.UUID.generate/0)
    meta = Keyword.get(opts, :meta, %{})

    Repo.transact(fn ->
      ledger =
        Ledger.create_changeset(%Ledger{}, %{
          company_id: company_id,
          amount: amount,
          reason: reason,
          reference_type: ref_type,
          reference_id: ref_id,
          tick: tick,
          idempotency_key: idempotency_key,
          meta: meta
        })

      with {:ok, company} <- fetch_company_for_update(company_id),
           {:ok, _ledger} <- Repo.insert(ledger),
           :ok <- check_sufficient_funds(company, amount),
           {:ok, updated_company} <- update_company_treasury(company, amount) do
        {:ok, updated_company}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp update_company_treasury(company, amount) do
    company
    |> Company.update_treasury_changeset(amount)
    |> Repo.update()
  end

  defp fetch_company_for_update(company_id) do
    Company
    |> where(id: ^company_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:company_not_found)
  end

  defp check_sufficient_funds(company, amount) do
    if amount < 0 && company.treasury + amount < 0 do
      {:error, :insufficient_funds}
    else
      :ok
    end
  end
end
