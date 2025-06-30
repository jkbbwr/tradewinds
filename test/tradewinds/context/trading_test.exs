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
end
