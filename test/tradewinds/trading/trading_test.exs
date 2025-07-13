defmodule Tradewinds.TradingTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Trading
  alias Tradewinds.Factory

  describe "quotes" do
    test "buy_from_trader_quote/3 returns a quote" do
      trader = Factory.insert(:trader)
      item = Factory.insert(:item)
      Factory.insert(:trader_inventory, trader: trader, item: item, stock: 100)
      Factory.insert(:trader_plan, trader: trader, item: item)

      assert {:ok, quote} = Trading.buy_from_trader_quote(trader, item, 50)
      assert is_binary(quote)
    end

    test "sell_to_trader_quote/4 returns a quote" do
      trader = Factory.insert(:trader)
      item = Factory.insert(:item)
      Factory.insert(:trader_inventory, trader: trader, item: item, stock: 100)
      Factory.insert(:trader_plan, trader: trader, item: item)

      assert {:ok, quote} = Trading.sell_to_trader_quote(trader, item, 50, 1)
      assert is_binary(quote)
    end
  end

  describe "trading" do
    setup do
      player = Factory.insert(:player)
      company = Factory.insert(:company, treasury: 10_000)
      port = Factory.insert(:port)
      item = Factory.insert(:item)
      trader = Factory.insert(:trader, port: port)
      Factory.insert(:trader_inventory, trader: trader, item: item, stock: 100)
      Factory.insert(:trader_plan, trader: trader, item: item)
      Factory.insert(:office, company: company, port: port)

      %{player: player, company: company, item: item, trader: trader}
    end

    test "buy_from_trader/6 successfully buys from a trader", %{
      player: player,
      company: company,
      item: item,
      trader: trader
    } do
      warehouse = Factory.insert(:warehouse, company: company, port: trader.port)
      {:ok, quote} = Trading.buy_from_trader_quote(trader, item, 50)
      inventories = [%{type: :warehouse, id: warehouse.id, amount: 50}]

      assert {:ok, :bought} = Trading.buy_from_trader(trader, company, quote, inventories, player, 1)
    end

    test "sell_to_trader/6 successfully sells to a trader", %{
      player: player,
      company: company,
      item: item,
      trader: trader
    } do
      warehouse = Factory.insert(:warehouse, company: company, port: trader.port)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 100)
      {:ok, quote} = Trading.sell_to_trader_quote(trader, item, 50, 1)
      inventories = [%{type: :warehouse, id: warehouse.id, amount: 50}]

      assert {:ok, :sold} = Trading.sell_to_trader(player, company, trader, quote, inventories, 1)
    end
  end
end
