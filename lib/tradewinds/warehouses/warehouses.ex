defmodule Tradewinds.Warehouses do
  @moduledoc """
  The Warehouses context.
  """
  alias Tradewinds.Repo
  alias Tradewinds.Warehouses.WarehouseInventory

  @doc """
  Stores a specific amount of an item in a warehouse.
  """
  def store(warehouse, item, amount) do
    %WarehouseInventory{}
    |> WarehouseInventory.create_changeset(%{
      warehouse_id: warehouse.id,
      item_id: item.id,
      amount: amount
    })
    |> Repo.insert(
      on_conflict: [inc: [amount: amount]],
      conflict_target: [:warehouse_id, :item_id]
    )
  end

  @doc """
  Withdraws a specific amount of an item from a warehouse.
  """
  def withdraw(warehouse, item, amount) do
    Repo.transact(fn ->
      with {:ok, inventory} <- fetch_inventory_by_item_id(warehouse, item) do
        cond do
          inventory.amount == amount ->
            Repo.delete(inventory)

          inventory.amount < amount ->
            {:error, :not_enough_inventory}

          inventory.amount > amount ->
            inventory
            |> WarehouseInventory.update_amount_changeset(inventory.amount - amount)
            |> Repo.update()
        end
      end
    end)
  end

  defp fetch_inventory_by_item_id(warehouse, item) do
    Repo.get_by(WarehouseInventory,
      warehouse_id: warehouse.id,
      item_id: item.id
    )
    |> Repo.ok_or(:warehouse_inventory_not_found)
  end
end
