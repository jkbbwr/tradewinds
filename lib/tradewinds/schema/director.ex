defmodule Tradewinds.Schema.Director do
  use Tradewinds.Schema

  schema "director" do
    belongs_to :company, Tradewinds.Schema.Company, foreign_key: :company_id
    belongs_to :player, Tradewinds.Schema.Player, foreign_key: :player_id

    timestamps()
  end
end
