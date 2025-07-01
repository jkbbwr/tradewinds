defmodule Tradewinds.Schema.Trade do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "trade" do
    field :amount, :integer
    field :price, :integer
    field :game_tick, :integer
    field :action, Ecto.Enum, values: [:sell, :buy]

    belongs_to :item, Tradewinds.Schema.Item
    belongs_to :trader, Tradewinds.Schema.Trader
    belongs_to :company, Tradewinds.Schema.Company
    belongs_to :player, Tradewinds.Schema.Player

    timestamps()
  end

  @doc """
  Builds a changeset for the trade schema.
  """
  def changeset(trade, attrs) do
    trade
    |> cast(attrs, [
      :amount,
      :price,
      :game_tick,
      :action,
      :trader_id,
      :company_id,
      :player_id,
      :item_id
    ])
    |> validate_required([
      :amount,
      :price,
      :game_tick,
      :action,
      :trader_id,
      :company_id,
      :player_id,
      :item_id
    ])
  end
end
