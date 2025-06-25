defmodule Tradewinds.Repo.CompanyRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.Company

  def create(name, ticker, treasury, home_port_id, officers \\ []) do
    %Company{}
    |> Company.create_changeset(%{
      name: name,
      ticker: ticker,
      treasury: treasury,
      home_port_id: home_port_id,
      officers: officers
    })
    |> Repo.insert()
  end
end
