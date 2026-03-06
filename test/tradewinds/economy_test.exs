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
        occurred_at: ~U[2026-03-06 00:00:00Z],
        quantity: 100,
        price: 50,
        source: :market,
        port_id: port.id,
        good_id: good.id,
        buyer_id: buyer.id,
        seller_id: seller.id
      }

      assert {:ok, %TradeLog{} = log} = Economy.log_trade(attrs)
      assert DateTime.compare(log.occurred_at, ~U[2026-03-06 00:00:00Z]) == :eq
      assert log.quantity == 100
      assert log.price == 50
      assert log.source == :market
    end

    test "calculate_tax/2 calculates correct amount" do
      assert Economy.calculate_tax(10000, 500) == 500
      assert Economy.calculate_tax(10000, 200) == 200
      assert Economy.calculate_tax(5000, 500) == 250
      assert Economy.calculate_tax(1, 100) == 0 # Rounding floor
    end

    test "calculate_tax_for_port/2 uses port's tax rate" do
      port = insert(:port, tax_rate_bps: 300)
      assert Economy.calculate_tax_for_port(10000, port.id) == 300
    end

    test "net_player_flow_from_npc/4 aggregates correctly" do
      port = insert(:port)
      good = insert(:good)
      company = insert(:company)
      npc_id = Economy.system_npc_id()

      start_time = ~U[2026-03-06 00:00:00Z]
      time1 = ~U[2026-03-06 00:00:01Z]
      time5 = ~U[2026-03-06 00:00:05Z]
      time10 = ~U[2026-03-06 00:00:10Z]
      end_time = ~U[2026-03-06 00:00:20Z]

      # Player buys 100 from NPC
      insert(:trade_log, %{
        occurred_at: time1,
        quantity: 100,
        source: :npc_trader,
        port: port,
        good: good,
        buyer_id: company.id,
        seller_id: npc_id
      })

      # Player sells 40 to NPC
      insert(:trade_log, %{
        occurred_at: time5,
        quantity: 40,
        source: :npc_trader,
        port: port,
        good: good,
        buyer_id: npc_id,
        seller_id: company.id
      })

      # Market trade (should be ignored)
      insert(:trade_log, %{
        occurred_at: time10,
        quantity: 50,
        source: :market,
        port: port,
        good: good
      })

      assert Economy.net_player_flow_from_npc(port.id, good.id, start_time, end_time) == 60
    end

    test "vwap/4 calculates correctly" do
      port = insert(:port)
      good = insert(:good)

      start_time = ~U[2026-03-06 00:00:00Z]
      time1 = ~U[2026-03-06 00:00:01Z]
      time2 = ~U[2026-03-06 00:00:02Z]
      end_time = ~U[2026-03-06 00:00:10Z]

      insert(:trade_log, %{occurred_at: time1, quantity: 10, price: 100, port: port, good: good})
      insert(:trade_log, %{occurred_at: time2, quantity: 20, price: 130, port: port, good: good})

      # Should be (10*100 + 20*130) / (10 + 20) = (1000 + 2600) / 30 = 3600 / 30 = 120
      assert Economy.vwap(port.id, good.id, start_time, end_time) == 120.0
    end
  end

  describe "economy shocks" do
    test "get_active_modifiers/3 aggregates multiple shocks" do
      port = insert(:port)
      good = insert(:good)

      t0 = ~U[2026-03-06 00:00:00Z]
      t5 = ~U[2026-03-06 00:00:05Z]
      t10 = ~U[2026-03-06 00:00:10Z]
      t15 = ~U[2026-03-06 00:00:15Z]
      t20 = ~U[2026-03-06 00:00:20Z]
      t100 = ~U[2026-03-06 00:01:40Z]

      # Global price shock (1.5x)
      insert(:shock, %{
        name: "Global Inflation",
        price_modifier: 15_000,
        start_time: t0,
        end_time: t100
      })

      # Local demand shock (2.0x)
      insert(:shock, %{
        name: "Local Famine",
        port: port,
        good: good,
        demand_modifier: 20_000,
        start_time: t10,
        end_time: t20
      })

      # Paused shock (should be ignored)
      insert(:shock, %{
        name: "Paused Event",
        status: :paused,
        price_modifier: 50_000,
        start_time: t0
      })

      # At tick 5: Only global inflation applies
      mods = Economy.get_active_modifiers(port.id, good.id, t5)
      assert mods.price == 1.5
      assert mods.demand == 1.0

      # At tick 15: Both apply (1.5x price, 2.0x demand)
      mods = Economy.get_active_modifiers(port.id, good.id, t15)
      assert mods.price == 1.5
      assert mods.demand == 2.0
    end
  end
end
