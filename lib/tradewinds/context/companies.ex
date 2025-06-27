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
  import Ecto.Query

  def create_company(name, ticker, treasury, home_port_id, directors) do
    %Company{}
    |> Company.create_changeset(%{
      name: name,
      ticker: ticker,
      treasury: treasury,
      home_port_id: home_port_id,
      directors: directors
    })
    |> Repo.insert()
  end

  def open_office(company, port) do
    %Office{}
    |> Office.create_changeset(%{company_id: company.id, port_id: port.id})
    |> Repo.insert()
  end

  def close_office(company, port) do
    Repo.get_by(Office, company_id: company.id, port_id: port.id)
    |> Repo.delete()
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
      Repo.exists?(
        from(s in Ship, where: s.company_id == ^company.id and s.port_id == ^port_id)
      )

    if is_headquarters or has_office or has_ship do
      :ok
    else
      {:error, :no_presence_in_port}
    end
  end
end
