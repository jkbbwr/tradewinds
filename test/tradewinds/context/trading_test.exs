defmodule Tradewinds.TradingTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.Trading

  describe "get_stock_in_port/3" do
    test "returns an empty list when there is no ship and no warehouse" do
      company = insert(:company)
      port = insert(:port)
      item = insert(:item)

      assert Trading.get_stock_in_port(company.id, port.id, item.id) == []
    end

    test "returns an empty list when there is a warehouse but no ship" do
      company = insert(:company)
      port = insert(:port)
      item = insert(:item)
      insert(:warehouse, company: company, port: port)

      assert Trading.get_stock_in_port(company.id, port.id, item.id) == []
    end

    test "returns an empty list when there is a ship but no warehouse" do
      company = insert(:company)
      port = insert(:port)
      item = insert(:item)
      insert(:ship, company: company, port: port)

      assert Trading.get_stock_in_port(company.id, port.id, item.id) == []
    end

    test "returns only ship inventory when there is a ship with stock but no warehouse" do
      company = insert(:company)
      port = insert(:port)
      item = insert(:item)
      ship = insert(:ship, company: company, port: port)
      ship_inventory = insert(:ship_inventory, ship: ship, item: item, amount: 10)

      results = Trading.get_stock_in_port(company.id, port.id, item.id)
      assert length(results) == 1
      assert %{type: "ship", id: ship_inventory.id, amount: 10} in results
    end

    test "returns only warehouse inventory when there is a warehouse with stock but no ship" do
      company = insert(:company)
      port = insert(:port)
      item = insert(:item)
      warehouse = insert(:warehouse, company: company, port: port)
      warehouse_inventory = insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 20)

      results = Trading.get_stock_in_port(company.id, port.id, item.id)
      assert length(results) == 1
      assert %{type: "warehouse", id: warehouse_inventory.id, amount: 20} in results
    end

    test "returns stock from both ship and warehouse" do
      company = insert(:company)
      port = insert(:port)
      item = insert(:item)
      ship = insert(:ship, company: company, port: port)
      warehouse = insert(:warehouse, company: company, port: port)
      ship_inventory = insert(:ship_inventory, ship: ship, item: item, amount: 10)
      warehouse_inventory = insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 20)

      results = Trading.get_stock_in_port(company.id, port.id, item.id)
      assert length(results) == 2
      assert %{type: "ship", id: ship_inventory.id, amount: 10} in results
      assert %{type: "warehouse", id: warehouse_inventory.id, amount: 20} in results
    end
  end

  describe "sell_to_player/4" do
    test "successfully sells to player" do
      player = insert(:player)
      company = insert(:company, treasury: 1000)
      port = insert(:port)
      item = insert(:item)
      trader = insert(:trader, port_id: port.id) |> Repo.preload(:port)
      insert(:trader_inventory, trader: trader, item: item, stock: 100)
      insert(:company_agent, company: company, port: port)

      quote = Phoenix.Token.sign(TradewindsWeb.Endpoint, "trader quote", [item.id, 10, 50, 1])

      assert {:ok, :sold} == Trading.sell_to_player(player, company, trader, quote)
    end
  end

  describe "buy_from_player/4" do
    test "successfully buys from player" do
      player = insert(:player)
      company = insert(:company, treasury: 1000)
      port = insert(:port)
      item = insert(:item)
      trader = insert(:trader, port_id: port.id) |> Repo.preload(:port)
      insert(:trader_inventory, trader: trader, item: item, stock: 100)
      insert(:trader_plan, trader: trader, item: item)
      insert(:company_agent, company: company, port: port)
      ship = insert(:ship, company: company, port: port)
      insert(:ship_inventory, ship: ship, item: item, amount: 20)

      quote = Phoenix.Token.sign(TradewindsWeb.Endpoint, "trader quote", [item.id, 10, 50, 1])

      assert {:ok, :bought} == Trading.buy_from_player(player, company, trader, quote)
    end
  end
end
