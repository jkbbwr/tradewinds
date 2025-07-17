defmodule Tradewinds.Ledger.NpcTrade do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Item
  alias Tradewinds.Trading.Trader
  alias Tradewinds.Companies.Company
  alias Tradewinds.Accounts.Player

  schema "npc_trade" do
    field :amount, :integer
    field :price, :integer
    field :game_tick, :integer

    field :action, Ecto.Enum,
      values: [:sell, :buy],
      comment: "from the players perspective always."

    belongs_to :item, Item
    belongs_to :trader, Trader
    belongs_to :company, Company
    belongs_to :player, Player

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
