defmodule Tradewinds.CompanyRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.Company
  alias Tradewinds.Schema.CompanyAgent
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
      directors: director
    })
    |> Repo.insert()
  end

  def fetch_company_by_id(id) do
    Repo.get(Company, id)
    |> Repo.ok_or("couldn't find company with id #{id}")
  end

  def create_office(company, port) do
    %Office{}
    |> Office.create_changeset(%{company_id: company.id, port_id: port.id})
    |> Repo.insert()
  end

  def delete_office(office) do
    office
    |> Repo.delete()
  end

  def fetch_ship(company_id) do
    Repo.get_by(Ship, company_id: company_id)
    |> Repo.ok_or("couldn't find ship for company_id #{company_id}")
  end

  def fetch_warehouse(company_id, port_id) do
    Repo.get_by(Warehouse, company_id: company_id, port_id: port_id)
    |> Repo.ok_or("couldn't find warehouse for company_id #{company_id} and port_id #{port_id}")
  end

  def find_or_create_warehouse(company, port) do
    case Repo.get_by(Warehouse, company_id: company.id, port_id: port.id) do
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

  def has_office_in_port?(company, port) do
    Repo.exists?(from(o in Office, where: o.company_id == ^company.id and o.port_id == ^port.id))
  end

  def has_ship_in_port?(company, port) do
    Repo.exists?(from(s in Ship, where: s.company_id == ^company.id and s.port_id == ^port.id))
  end

  def has_agent_in_port?(company, port) do
    Repo.exists?(
      from(ca in CompanyAgent, where: ca.company_id == ^company.id and ca.port_id == ^port.id)
    )
  end

  def update_warehouse_capacity(warehouse, desired_capacity) do
    warehouse
    |> Ecto.Changeset.change(%{capacity: desired_capacity})
    |> Repo.update()
  end

  def debit_treasury(company, amount) do
    company
    |> Ecto.Changeset.change(%{treasury: company.treasury - amount})
    |> Repo.update()
  end

  def credit_treasury(company, amount) do
    company
    |> Ecto.Changeset.change(%{treasury: company.treasury + amount})
    |> Repo.update()
  end
end
