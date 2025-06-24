defmodule Tradewinds.Schema.Officer do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "officer" do
    belongs_to :company, Tradewinds.Schema.Company
    belongs_to :player, Tradewinds.Schema.Player

    timestamps()
  end
end
