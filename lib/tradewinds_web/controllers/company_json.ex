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
