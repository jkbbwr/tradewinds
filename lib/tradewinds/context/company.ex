defmodule Tradewinds.Company do
  alias Tradewinds.Repo.CompanyRepo
  alias Tradewinds.Schema.Company

  defdelegate create(name, ticker, treasury, home_port_id, officers), to: CompanyRepo
end
