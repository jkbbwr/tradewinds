defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  Manages companies and their directors.
  """

  alias Tradewinds.CompanyRepo
  alias Tradewinds.Repo

  def create_company(name, ticker, treasury, home_port, directors) do
    CompanyRepo.create_company(name, ticker, treasury, home_port.id, directors)
  end

  def adjust_warehouse_capacity(company, port, desired_capacity) do
    Repo.transact(fn ->
      with :ok <- check_presence_in_port(company, port.id),
           {:ok, warehouse} <- CompanyRepo.find_or_create_warehouse(company, port),
           cost = calculate_cost(warehouse, desired_capacity, port.warehouse_cost),
           :ok <- check_sufficient_funds(company, cost),
           {:ok, _company} <- CompanyRepo.debit_treasury(company, cost) do
        CompanyRepo.update_warehouse_capacity(warehouse, desired_capacity)
      end
    end)
  end

  defp calculate_cost(warehouse, desired_capacity, cost_per_unit) do
    if desired_capacity > warehouse.capacity do
      (desired_capacity - warehouse.capacity) * cost_per_unit
    else
      0
    end
  end

  def check_sufficient_funds(company, amount) do
    if company.treasury >= amount do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end

  def check_presence_in_port(company, port) do
    is_headquarters = company.home_port_id == port.id
    has_office = CompanyRepo.has_office_in_port?(company, port)
    has_ship = CompanyRepo.has_ship_in_port?(company, port)
    has_agent = CompanyRepo.has_agent_in_port?(company, port)

    if is_headquarters or has_office or has_ship or has_agent do
      :ok
    else
      {:error, :no_presence_in_port}
    end
  end
end
