defmodule Tradewinds.LedgerTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Ledger
  alias Tradewinds.Factory

  describe "trades" do
    test "log_trade/8 creates a trade log" do
      player = Factory.insert(:player)
      company = Factory.insert(:company)
      item = Factory.insert(:item)
      trader = Factory.insert(:trader)

      assert {:ok, trade} =
               Ledger.log_npc_trade(player, company, item, trader, 10, 100, :buy, 1)

      assert trade.player_id == player.id
      assert trade.company_id == company.id
      assert trade.item_id == item.id
      assert trade.trader_id == trader.id
      assert trade.amount == 10
      assert trade.price == 100
      assert trade.action == :buy
      assert trade.game_tick == 1
    end
  end
end
