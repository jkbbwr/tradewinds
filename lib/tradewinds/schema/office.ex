defmodule Tradewinds.Schema.Office do
  use Tradewinds.Schema

  schema "offices" do
    belongs_to :company, Tradewinds.Schema.Company, foreign_key: :company_id
    belongs_to :port, Tradewinds.Schema.Port, foreign_key: :port_id

    timestamps()
  end
end
