defmodule TradewindsWeb.CompanyJSON do
  @moduledoc """
  Renders company data as JSON.
  """

  @doc """
  Renders the response for a newly created company.
  """
  def create(%{company: company}) do
    %{"company" => company(company)}
  end

  @doc """
  Renders a single company.
  """
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
