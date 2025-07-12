defmodule Tradewinds.Ledger do
  @moduledoc """
  The Ledger context, responsible for logging events.
  """
  alias Tradewinds.Repo
  alias Tradewinds.Ledger.Trade

  def log_trade(
        player,
        company,
        item,
        trader,
        amount,
        price,
        action,
        game_tick
      ) do
    %Trade{}
    |> Trade.changeset(%{
      player_id: player.id,
      company_id: company.id,
      item_id: item.id,
      trader_id: trader.id,
      amount: amount,
      price: price,
      action: action,
      game_tick: game_tick
    })
    |> Repo.insert()
  end
end
