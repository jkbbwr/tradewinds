defmodule TradewindsWeb.CompanyJSON do
  def index(%{companies: companies}) do
    %{data: for(company <- companies, do: data(company))}
  end

  def show(%{company: company}) do
    %{data: data(company)}
  end

  def economy(assigns) do
    %{
      data: %{
        treasury: assigns.treasury,
        reputation: assigns.reputation,
        ship_upkeep: assigns.ship_upkeep,
        warehouse_upkeep: assigns.warehouse_upkeep,
        total_upkeep: assigns.total_upkeep
      }
    }
  end

  def ledger(%{ledger: ledger}) do
    %{data: for(entry <- ledger, do: ledger_data(entry))}
  end

  def ledger_data(entry) do
    %{
      id: entry.id,
      company_id: entry.company_id,
      occurred_at: entry.occurred_at,
      amount: entry.amount,
      reason: entry.reason,
      reference_type: entry.reference_type,
      reference_id: entry.reference_id,
      idempotency_key: entry.idempotency_key,
      meta: entry.meta,
      inserted_at: entry.inserted_at
    }
  end

  def data(company) do
    %{
      id: company.id,
      name: company.name,
      ticker: company.ticker,
      treasury: company.treasury,
      reputation: company.reputation,
      status: company.status,
      home_port_id: company.home_port_id,
      inserted_at: company.inserted_at,
      updated_at: company.updated_at
    }
  end
end
