defmodule Tradewinds.Schema.Shipyard do
  use Tradewinds.Schema

  schema "shipyard" do
    belongs_to :port, Tradewinds.Schema.Port
    has_many :ships, Tradewinds.Schema.Ship
    timestamps()
  end
end
