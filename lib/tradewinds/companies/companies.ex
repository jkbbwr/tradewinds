defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  Manages companies and their directors.
  """
  alias Tradewinds.Companies.Company
  alias Tradewinds.Ships.Ship
  alias Tradewinds.Companies.CompanyAgent
  alias Tradewinds.Companies.Office
  alias Tradewinds.Warehouses.Warehouse
  alias Tradewinds.Repo
  import Ecto.Query

  @doc """
  Creates a new company.
  """
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

  @doc """
  Credits a company's treasury.
  """
  def credit_treasury(company, amount) do
    company
    |> Company.treasury_changeset(company.treasury + amount)
    |> Repo.update()
  end

  @doc """
  Debits a company's treasury.
  """
  def debit_treasury(company, amount) do
    company
    |> Company.treasury_changeset(company.treasury - amount)
    |> Repo.update()
  end

  @doc """
  Checks if a company has sufficient funds.
  """
  def check_sufficient_funds(company, amount) do
    if company.treasury >= amount do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end

  @doc """
  Checks if a company has a presence in a given port.
  """
  def check_presence_in_port(company, port) do
    is_headquarters = company.home_port_id == port.id
    has_office = has_office_in_port?(company, port)
    has_ship = has_ship_in_port?(company, port)
    has_agent = has_agent_in_port?(company, port)

    if is_headquarters or has_office or has_ship or has_agent do
      :ok
    else
      {:error, :no_presence_in_port}
    end
  end

  @doc """
  Checks if a company has an office in a given port.
  """
  def has_office_in_port?(company, port) do
    Repo.exists?(from(o in Office, where: o.company_id == ^company.id and o.port_id == ^port.id))
  end

  @doc """
  Checks if a company has a ship in a given port.
  """
  def has_ship_in_port?(company, port) do
    Repo.exists?(from(s in Ship, where: s.company_id == ^company.id and s.port_id == ^port.id))
  end

  @doc """
  Checks if a company has an agent in a given port.
  """
  def has_agent_in_port?(company, port) do
    Repo.exists?(
      from(ca in CompanyAgent, where: ca.company_id == ^company.id and ca.port_id == ^port.id)
    )
  end

  @doc """
  Hires a new agent for a company.
  """
  def hire_agent(company) do
    agent_count =
      Repo.aggregate(from(ca in CompanyAgent, where: ca.company_id == ^company.id), :count, :id)

    if agent_count >= 3 do
      {:error, :max_agents_reached}
    else
      %CompanyAgent{}
      |> CompanyAgent.create_changeset(%{
        company_id: company.id,
        port_id: company.home_port_id
      })
      |> Repo.insert()
    end
  end

  @doc """
  Fires an agent.
  """
  def fire_agent(agent) do
    Repo.delete(agent)
  end

  @doc """
  Fetches a ship belonging to a company.
  """
  def fetch_ship(company, id) do
    from(s in Ship, where: s.id == ^id and s.company_id == ^company.id)
    |> Repo.one()
    |> Repo.ok_or(:ship_not_found)
  end

  @doc """
  Fetches a warehouse belonging to a company.
  """
  def fetch_warehouse(company, id) do
    from(w in Warehouse, where: w.id == ^id and w.company_id == ^company.id)
    |> Repo.one()
    |> Repo.ok_or(:warehouse_not_found)
  end

  @doc """
  Fetches all ship inventories for a given item in a port.
  """
  def fetch_ship_inventories_in_port(company, port, item) do
    from(s in Ship,
      where: s.company_id == ^company.id and s.port_id == ^port.id,
      join: si in assoc(s, :inventory),
      where: si.item_id == ^item.id,
      select: %{type: :ship, id: s.id, amount: si.amount}
    )
    |> Repo.all()
  end

  @doc """
  Fetches all warehouse inventories for a given item in a port.
  """
  def fetch_warehouse_inventories_in_port(company, port, item) do
    from(w in Warehouse,
      where: w.company_id == ^company.id and w.port_id == ^port.id,
      join: wi in assoc(w, :inventory),
      where: wi.item_id == ^item.id,
      select: %{type: :warehouse, id: w.id, amount: wi.amount}
    )
    |> Repo.all()
  end
end
