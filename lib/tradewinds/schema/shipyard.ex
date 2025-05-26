defmodule Tradewinds.Schema.Shipyard do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "shipyard" do
    belongs_to :port, Tradewinds.Schema.Port
    has_many :ships, Tradewinds.Schema.Ship
    timestamps()
  end
end
