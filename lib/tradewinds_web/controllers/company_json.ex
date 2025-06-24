defmodule TradewindsWeb.CompanyJSON do
  def create(%{company: company}) do
    %{"company" => company(company)}
  end

  def company(company) do
    %{
      id: company.id,
      name: company.name,
      ticker: company.ticker,
      treasury: company.treasury,
      home_port_id: company.home_port_id,
      inserted_at: company.inserted_at,
      updated_at: company.updated_at
    }
  end
end
