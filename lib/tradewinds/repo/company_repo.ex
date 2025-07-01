defmodule Tradewinds.CompanyRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.CompanyAgent
  alias Tradewinds.Schema.Office
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Warehouse
  import Ecto.Query

  def fetch_ship(company_id) do
    Repo.fetch_by(Ship, company_id: company_id)
  end

  def fetch_warehouse(company_id, port_id) do
    Repo.fetch_by(Warehouse, company_id: company_id, port_id: port_id)
  end

  def find_or_create_warehouse(company, port) do
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
end
