defmodule Tradewinds.Trade.Trader do
  use Tradewinds.Schema

  schema "trader" do
    field :name, :string

    has_many :positions, Tradewinds.Trade.TraderPosition

    timestamps()
  end

  @doc """
  Builds a changeset for creating a top-level NPC Trader entity.
  """
  def changeset(trader, attrs) do
    trader
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
