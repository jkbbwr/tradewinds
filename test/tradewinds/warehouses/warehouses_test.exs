defmodule Tradewinds.WarehousesTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Warehouses
  alias Tradewinds.Factory

  describe "warehouse inventory" do
    test "store/3 adds items to a warehouse" do
      warehouse = Factory.insert(:warehouse)
      item = Factory.insert(:item)

      assert {:ok, :stored} = Warehouses.store(warehouse, item, 50)
      inventory =
        Repo.get_by(Tradewinds.Warehouses.WarehouseInventory,
          warehouse_id: warehouse.id,
          item_id: item.id
        )
      assert inventory.amount == 50
    end

    test "withdraw/3 removes items from a warehouse" do
      warehouse = Factory.insert(:warehouse)
      item = Factory.insert(:item)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 100)

      assert {:ok, _} = Warehouses.withdraw(warehouse, item, 50)
      inventory =
        Repo.get_by(Tradewinds.Warehouses.WarehouseInventory,
          warehouse_id: warehouse.id,
          item_id: item.id
        )
      assert inventory.amount == 50
    end

    test "withdraw/3 removes inventory if amount is zero" do
      warehouse = Factory.insert(:warehouse)
      item = Factory.insert(:item)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 100)

      assert {:ok, _} = Warehouses.withdraw(warehouse, item, 100)
      assert nil ==
               Repo.get_by(Tradewinds.Warehouses.WarehouseInventory,
                 warehouse_id: warehouse.id,
                 item_id: item.id
               )
    end

    test "withdraw/3 returns error if not enough inventory" do
      warehouse = Factory.insert(:warehouse)
      item = Factory.insert(:item)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 50)

      assert {:error, :not_enough_inventory} = Warehouses.withdraw(warehouse, item, 100)
    end
  end
end
