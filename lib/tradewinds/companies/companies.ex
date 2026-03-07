defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  Handles company creation, directorship mapping, financial transactions, and reputation.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Scope
  alias Tradewinds.Companies.Company
  alias Tradewinds.Companies.Director
  alias Tradewinds.Companies.Ledger
  alias Tradewinds.Accounts.Player

  @doc """
  Creates a new company and automatically assigns the calling player as its first director.
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

  @doc """
  Assigns an existing player (via scope) as a director to a company.
  """
  def add_director(%Scope{} = scope, %Company{} = company) do
    with :ok <- Scope.authorizes?(scope, company.id) do
      %Director{}
      |> Director.create_changeset(%{company_id: company.id, player_id: scope.player.id})
      |> Repo.insert()
    end
  end

  @doc """
  Retrieves a list of company IDs that a given player is authorized to act on behalf of.
  """
  def list_player_company_ids(%Player{} = player) do
    player
    |> Ecto.assoc(:directorships)
    |> select([d], d.company_id)
    |> Repo.all()
  end

  @doc """
  Atomically records a financial transaction to the ledger and updates the company's treasury.
  Fails and rolls back if the company lacks sufficient funds for a deduction.
  """
  def record_transaction(
        company_id,
        amount,
        reason,
        ref_type,
        ref_id,
        occurred_at,
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
          occurred_at: occurred_at,
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

  # Updates the cached treasury balance on the company record.
  defp update_company_treasury(company, amount) do
    company
    |> Company.update_treasury_changeset(amount)
    |> Repo.update()
  end

  @doc """
  Fetches a single company by ID.
  """
  def fetch_company(id) do
    Company
    |> Repo.get(id)
    |> Repo.ok_or(:company_not_found)
  end

  # Fetches and locks a company record for transaction safety.
  defp fetch_company_for_update(company_id) do
    Company
    |> where(id: ^company_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:company_not_found)
  end

  # Validates that a deduction will not push the company's treasury below zero.
  defp check_sufficient_funds(company, amount) do
    if amount < 0 && company.treasury + amount < 0 do
      {:error, :insufficient_funds}
    else
      :ok
    end
  end

  @doc """
  Processes the monthly upkeep for a company.
  Delegates to Fleet and Logistics contexts to deduct upkeep from the treasury.
  If funds are insufficient at any point, the transaction rolls back and the company is marked as bankrupt.
  """
  def process_monthly_upkeep(company_id, now \\ DateTime.utc_now()) do
    result =
      Repo.transact(fn ->
        with {:ok, _} <- Tradewinds.Fleet.process_upkeep(company_id, now),
             {:ok, _} <- Tradewinds.Logistics.process_upkeep(company_id, now) do
          {:ok, :paid}
        else
          {:error, reason} -> Repo.rollback(reason)
        end
      end)

    case result do
      {:ok, :paid} ->
        {:ok, :paid}

      {:error, :insufficient_funds} ->
        set_bankrupt(company_id)
        {:error, :bankrupt}

      err ->
        err
    end
  end

  @doc """
  Marks a company as bankrupt.
  """
  def set_bankrupt(company_id) do
    with {:ok, company} <- fetch_company(company_id) do
      company
      |> Company.update_status_changeset(:bankrupt)
      |> Repo.update()
    end
  end

  @doc """
  Calculates the recommended bailout amount for a company.
  Covers 3 months worth of the current level of combined upkeep (ships + warehouses).
  """
  def calculate_bailout(company_id) do
    ship_upkeep = Tradewinds.Fleet.calculate_total_upkeep(company_id)
    warehouse_upkeep = Tradewinds.Logistics.calculate_total_upkeep(company_id)
    (ship_upkeep + warehouse_upkeep) * 3
  end

  @doc """
  Administrative bailout to clear a company's bankruptcy.
  Injects treasury funds and resets status to :active.
  """
  def bailout(company_id, amount) when amount >= 0 do
    Repo.transact(fn ->
      now = DateTime.utc_now()

      with {:ok, _} <- fetch_company_for_update(company_id),
           {:ok, company} <- record_transaction(company_id, amount, :bailout, :system, company_id, now),
           {:ok, updated_company} <-
             company
             |> Company.update_status_changeset(:active)
             |> Repo.update() do
        {:ok, updated_company}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Atomically updates a company's reputation by a given delta.
  """
  def update_reputation(company_id, delta) do
    Repo.transact(fn ->
      with {:ok, company} <- fetch_company_for_update(company_id),
           {:ok, updated_company} <-
             company
             |> Company.update_reputation_changeset(delta)
             |> Repo.update() do
        {:ok, updated_company}
      end
    end)
  end

  @doc """
  Emits telemetry stats for the Companies context.
  """
  def emit_stats do
    stats = %{
      total_treasury: Repo.aggregate(Company, :sum, :treasury) || 0,
      bankrupt_count: Repo.aggregate(from(c in Company, where: c.status == :bankrupt), :count, :id)
    }

    :telemetry.execute([:tradewinds, :companies, :stats], stats)
  end
end
