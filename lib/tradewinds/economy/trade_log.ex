defmodule Tradewinds.Economy.TradeLog do
  use Tradewinds.Schema

  schema "trade_log" do
    field :tick, :integer
    field :quantity, :integer
    field :price, :integer
    field :source, Ecto.Enum, values: [:market, :npc_trader, :contract_execution]
    field :buyer_id, :binary_id
    field :seller_id, :binary_id

    belongs_to :port, Tradewinds.World.Port
    belongs_to :good, Tradewinds.World.Good

    timestamps(updated_at: false)
  end

  @doc """
  Builds a changeset for recording an immutable trade execution log.
  """
  def create_changeset(trade_log, attrs) do
    trade_log
    |> cast(attrs, [:tick, :quantity, :price, :source, :port_id, :good_id, :buyer_id, :seller_id])
    |> validate_required([:tick, :quantity, :price, :source, :port_id, :good_id, :buyer_id, :seller_id])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:price, greater_than: 0)
    |> foreign_key_constraint(:port_id)
    |> foreign_key_constraint(:good_id)
  end
end
