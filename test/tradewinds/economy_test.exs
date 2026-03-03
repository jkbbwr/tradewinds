defmodule Tradewinds.EconomyTest do
  use Tradewinds.DataCase
  alias Tradewinds.Economy
  alias Tradewinds.Economy.TradeLog
  import Tradewinds.Factory

  describe "trade logs" do
    test "log_trade/1 creates a trade log entry" do
      port = insert(:port)
      good = insert(:good)
      buyer = insert(:company)
      seller = insert(:company)

      attrs = %{
        tick: 10,
        quantity: 100,
        price: 50,
        source: :market,
        port_id: port.id,
        good_id: good.id,
        buyer_id: buyer.id,
        seller_id: seller.id
      }

      assert {:ok, %TradeLog{} = log} = Economy.log_trade(attrs)
      assert log.tick == 10
      assert log.quantity == 100
      assert log.price == 50
      assert log.source == :market
    end

    test "net_player_flow_from_npc/4 aggregates correctly" do
      port = insert(:port)
      good = insert(:good)
      company = insert(:company)
      npc_id = Economy.system_npc_id()

      # Player buys 100 from NPC
      insert(:trade_log, %{
        tick: 1,
        quantity: 100,
        source: :npc_trader,
        port: port,
        good: good,
        buyer_id: company.id,
        seller_id: npc_id
      })

      # Player sells 40 to NPC
      insert(:trade_log, %{
        tick: 5,
        quantity: 40,
        source: :npc_trader,
        port: port,
        good: good,
        buyer_id: npc_id,
        seller_id: company.id
      })

      # Market trade (should be ignored)
      insert(:trade_log, %{
        tick: 10,
        quantity: 50,
        source: :market,
        port: port,
        good: good
      })

      assert Economy.net_player_flow_from_npc(port.id, good.id, 0, 20) == 60
    end

    test "vwap/4 calculates correctly" do
      port = insert(:port)
      good = insert(:good)

      insert(:trade_log, %{tick: 1, quantity: 10, price: 100, port: port, good: good})
      insert(:trade_log, %{tick: 2, quantity: 20, price: 130, port: port, good: good})

      # Should be (10*100 + 20*130) / (10 + 20) = (1000 + 2600) / 30 = 3600 / 30 = 120
      assert Economy.vwap(port.id, good.id, 0, 10) == 120.0
    end
  end

  describe "economy shocks" do
    test "get_active_modifiers/3 aggregates multiple shocks" do
      port = insert(:port)
      good = insert(:good)

      # Global price shock (1.5x)
      insert(:shock, %{
        name: "Global Inflation",
        price_modifier: 15_000,
        start_tick: 0,
        end_tick: 100
      })

      # Local demand shock (2.0x)
      insert(:shock, %{
        name: "Local Famine",
        port: port,
        good: good,
        demand_modifier: 20_000,
        start_tick: 10,
        end_tick: 20
      })

      # Paused shock (should be ignored)
      insert(:shock, %{
        name: "Paused Event",
        status: :paused,
        price_modifier: 50_000,
        start_tick: 0
      })

      # At tick 5: Only global inflation applies
      mods = Economy.get_active_modifiers(port.id, good.id, 5)
      assert mods.price == 1.5
      assert mods.demand == 1.0

      # At tick 15: Both apply (1.5x price, 2.0x demand)
      mods = Economy.get_active_modifiers(port.id, good.id, 15)
      assert mods.price == 1.5
      assert mods.demand == 2.0
    end
  end
end
