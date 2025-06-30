defmodule Tradewinds.Schema.Trade do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "trades" do
    field :amount, :integer
    field :price, :integer
    field :game_tick, :integer
    field :state, Ecto.Enum, values: [:sell, :buy]

    belongs_to :item, Tradewinds.Schema.Item
    belongs_to :port, Tradewinds.Schema.Port
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
      :good_id,
      :port_id,
      :company_id,
      :player_id
    ])
    |> validate_required([
      :amount,
      :price,
      :game_tick,
      :action,
      :good_id,
      :port_id,
      :company_id,
      :player_id
    ])
  end
end
