defmodule Tradewinds.Companies do
  @moduledoc """
  The Companies context.
  Manages companies and their directors.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Company
  alias Tradewinds.Schema.Director

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
end
