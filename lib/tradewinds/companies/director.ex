defmodule Tradewinds.Companies.Director do
  use Tradewinds.Schema

  schema "director" do
    belongs_to :company, Tradewinds.Companies.Company, foreign_key: :company_id
    belongs_to :player, Tradewinds.Accounts.Player, foreign_key: :player_id

    timestamps()
  end
end
