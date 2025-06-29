defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  Manages companies and their directors.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Company
  alias Tradewinds.Schema.Director
  alias Tradewinds.Schema.Office
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Warehouse
  import Ecto.Query

  def create_company(name, ticker, treasury, home_port_id, director) do
    %Company{}
    |> Company.create_changeset(%{
      name: name,
      ticker: ticker,
      treasury: treasury,
      home_port_id: home_port_id,
      director: director
    })
    |> Repo.insert()
  end

  def open_office(company, port) do
    %Office{}
    |> Office.create_changeset(%{company_id: company.id, port_id: port.id})
    |> Repo.insert()
  end

  def close_office(company, port) do
    with {:ok, office} <- Repo.fetch_by(Office, company_id: company.id, port_id: port.id) do
      Repo.delete(office)
    end
  end

  def adjust_warehouse_capacity(company, port, desired_capacity) do
    Repo.transact(fn ->
      with :ok <- check_presence_in_port(company, port.id),
           {:ok, warehouse} <- find_or_create_warehouse(company, port),
           cost = calculate_cost(warehouse, desired_capacity, port.warehouse_cost),
           :ok <- check_sufficient_funds(company, cost),
           {:ok, updated_warehouse} <- update_warehouse_capacity(warehouse, desired_capacity),
           {:ok, _company} <- debit_treasury(company, cost) do
        {:ok, updated_warehouse}
      end
    end)
  end

  defp find_or_create_warehouse(company, port) do
    case Repo.fetch_by(Warehouse, company_id: company.id, port_id: port.id) do
      {:ok, warehouse} ->
        {:ok, warehouse}

      {:error, :not_found} ->
        %Warehouse{}
        |> Warehouse.create_changeset(%{
          company_id: company.id,
          port_id: port.id,
          capacity: 0
        })
        |> Repo.insert()
    end
  end

  defp calculate_cost(warehouse, desired_capacity, cost_per_unit) do
    if desired_capacity > warehouse.capacity do
      (desired_capacity - warehouse.capacity) * cost_per_unit
    else
      0
    end
  end

  defp update_warehouse_capacity(warehouse, desired_capacity) do
    warehouse
    |> Ecto.Changeset.change(%{capacity: desired_capacity})
    |> Repo.update()
  end

  def debit_treasury(company, amount) do
    company
    |> Ecto.Changeset.change(%{treasury: company.treasury - amount})
    |> Repo.update()
  end

  def check_sufficient_funds(company, amount) do
    if company.treasury >= amount do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end

  def check_presence_in_port(company, port_id) do
    is_headquarters = company.home_port_id == port_id

    has_office =
      Repo.exists?(
        from(o in Office, where: o.company_id == ^company.id and o.port_id == ^port_id)
      )

    has_ship =
      Repo.exists?(from(s in Ship, where: s.company_id == ^company.id and s.port_id == ^port_id))

    if is_headquarters or has_office or has_ship do
      :ok
    else
      {:error, :no_presence_in_port}
    end
  end
end
