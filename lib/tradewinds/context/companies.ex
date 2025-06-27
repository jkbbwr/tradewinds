defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  Manages companies and their directors.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Company
  alias Tradewinds.Schema.Director
  alias Tradewinds.Schema.Office

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
end
