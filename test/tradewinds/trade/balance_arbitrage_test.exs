defmodule Tradewinds.Trade.BalanceArbitrageTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Trade
  alias Tradewinds.Trade.TraderPosition
  alias Tradewinds.Trade.ArbitrageLog

  test "balance_arbitrage squeezes highly profitable margins" do
    good = insert(:good, base_price: 100)
    cheap_port = insert(:port)
    expensive_port = insert(:port)
    trader = insert(:trader)

    cheap_pos =
      insert(:trader_position,
        trader: trader,
        port: cheap_port,
        good: good,
        stock: 1000,
        target_stock: 100,
        elasticity: 1.0,
        ask_spread: 0.0,
        bid_spread: 0.0,
        supply_rate: 0.05,
        demand_rate: 0.05
      )

    exp_pos =
      insert(:trader_position,
        trader: trader,
        port: expensive_port,
        good: good,
        stock: 10,
        target_stock: 100,
        elasticity: 1.0,
        ask_spread: 0.0,
        bid_spread: 0.0,
        supply_rate: 0.05,
        demand_rate: 0.05
      )

    Trade.balance_arbitrage()

    updated_cheap = Repo.get!(TraderPosition, cheap_pos.id)
    updated_exp = Repo.get!(TraderPosition, exp_pos.id)

    assert updated_cheap.target_stock == round(100 * 1.01)
    assert_in_delta updated_cheap.supply_rate, 0.05 * 0.998, 0.0001
    assert_in_delta updated_cheap.demand_rate, 0.05 * 1.002, 0.0001

    # Target decreases, but min limit is 100
    assert updated_exp.target_stock == 100
    assert_in_delta updated_exp.supply_rate, 0.05 * 1.002, 0.0001
    assert_in_delta updated_exp.demand_rate, 0.05 * 0.998, 0.0001

    log = Repo.one(ArbitrageLog)
    assert log
    assert log.action == "squeezed"
    assert log.good_id == good.id
  end

  test "balance_arbitrage stretches unprofitable margins" do
    good = insert(:good, base_price: 100)

    p1 =
      insert(:trader_position,
        good: good,
        stock: 100,
        target_stock: 100,
        elasticity: 1.0,
        ask_spread: 0.0,
        bid_spread: 0.0,
        supply_rate: 0.05,
        demand_rate: 0.05
      )

    p2 =
      insert(:trader_position,
        good: good,
        stock: 95,
        target_stock: 100,
        elasticity: 1.0,
        ask_spread: 0.0,
        bid_spread: 0.0,
        supply_rate: 0.05,
        demand_rate: 0.05
      )

    Trade.balance_arbitrage()

    log = Repo.one(ArbitrageLog)
    assert log
    assert log.action == "stretched"

    updated1 = Repo.get!(TraderPosition, p1.id)
    updated2 = Repo.get!(TraderPosition, p2.id)

    targets = [updated1.target_stock, updated2.target_stock]
    assert Enum.member?(targets, 105)
  end

  test "balance_arbitrage skips goods with active shocks" do
    good = insert(:good, base_price: 100)
    cheap_port = insert(:port)
    expensive_port = insert(:port)
    trader = insert(:trader)

    cheap_pos =
      insert(:trader_position,
        trader: trader,
        port: cheap_port,
        good: good,
        stock: 1000,
        target_stock: 100,
        elasticity: 1.0,
        ask_spread: 0.0,
        bid_spread: 0.0,
        supply_rate: 0.05,
        demand_rate: 0.05
      )

    insert(:trader_position,
      trader: trader,
      port: expensive_port,
      good: good,
      stock: 10,
      target_stock: 100,
      elasticity: 1.0,
      ask_spread: 0.0,
      bid_spread: 0.0,
      supply_rate: 0.05,
      demand_rate: 0.05
    )

    now = DateTime.utc_now()

    insert(:shock,
      status: :active,
      start_time: DateTime.add(now, -60, :second),
      port_id: cheap_port.id,
      price_modifier: 20000
    )

    Trade.balance_arbitrage()

    assert Repo.one(ArbitrageLog) == nil

    updated_cheap = Repo.get!(TraderPosition, cheap_pos.id)
    assert updated_cheap.target_stock == 100
  end
end
