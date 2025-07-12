defmodule Tradewinds.Trading.Trader do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Port

  schema "trader" do
    field :name, :string
    belongs_to :port, Port

    timestamps()
  end

  def changeset(trader, attrs) do
    trader
    |> cast(attrs, [:name, :port_id])
    |> validate_required([:name, :port_id])
  end
end
