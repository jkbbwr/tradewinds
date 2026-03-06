defmodule Tradewinds.Logistics do
  @moduledoc """
  The Logistics context.
  Handles warehouse management, storage capacity, and inventory movement.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Scope
  alias Tradewinds.Companies
  alias Tradewinds.Logistics.Warehouse
  alias Tradewinds.Logistics.WarehouseInventory

  @doc """
  Adds a specified quantity of a good to a warehouse.
  Enforces capacity limits and uses an upsert (on_conflict inc) to update existing inventory.
  """
  def add_cargo(warehouse_id, good_id, quantity) when quantity > 0 do
    Repo.transact(fn ->
      with {:ok, warehouse} <- fetch_warehouse_for_update(warehouse_id),
           {:ok, current_total} <- current_inventory_total(warehouse_id),
           :ok <- check_capacity(warehouse, current_total, quantity) do
        %WarehouseInventory{}
        |> WarehouseInventory.create_changeset(%{
          warehouse_id: warehouse_id,
          good_id: good_id,
          quantity: quantity
        })
        |> Repo.insert(
          on_conflict: from(i in WarehouseInventory, update: [inc: [quantity: ^quantity]]),
          conflict_target: [:warehouse_id, :good_id]
        )
      end
    end)
  end

  def process_upkeep(company_id, now) do
    Repo.transact(fn ->
      cost = calculate_total_upkeep(company_id)

      if cost > 0 do
        Companies.record_transaction(company_id, -cost, :warehouse_upkeep, :warehouse, company_id, now)
      else
        {:ok, 0}
      end
    end)
  end

  @doc """
  Calculates the cost to upgrade a warehouse to the next tier.
  Cost formula: 100 * 1.1^(tier-1)
  """
  def upgrade_cost(%Warehouse{level: level}) do
    (100 * :math.pow(1.1, level - 1)) |> trunc()
  end

  def upgrade_cost(warehouse_id) do
    with {:ok, warehouse} <- fetch_warehouse(warehouse_id) do
      {:ok, upgrade_cost(warehouse)}
    end
  end

  @doc """
  Calculates the monthly upkeep cost for a warehouse.
  Base rate per 10 capacity: 10 * 1.05^(tier-1)
  Total cost = (capacity / 10) * base_rate
  """
  def upkeep_cost(%Warehouse{level: level, capacity: capacity}) do
    base_rate = (10 * :math.pow(1.05, level - 1)) |> trunc()
    div(capacity, 10) * base_rate
  end

  def upkeep_cost(warehouse_id) do
    with {:ok, warehouse} <- fetch_warehouse(warehouse_id) do
      {:ok, upkeep_cost(warehouse)}
    end
  end

  @doc """
  Calculates the total monthly upkeep cost for all warehouses owned by a company.
  """
  def calculate_total_upkeep(company_id) do
    # We fetch all warehouses because the cost is non-linear (depends on level and capacity)
    Warehouse
    |> where(company_id: ^company_id)
    |> Repo.all()
    |> Enum.reduce(0, fn warehouse, acc -> acc + upkeep_cost(warehouse) end)
  end

  @doc """
  Upgrades a warehouse to the next tier, increasing its level and capacity.
  Charges the company's treasury for the upgrade cost.
  """
  def grow_warehouse(warehouse_id) do
    Repo.transact(fn ->
      with {:ok, warehouse} <- fetch_warehouse_for_update(warehouse_id),
           cost <- upgrade_cost(warehouse),
           now = DateTime.utc_now(),
           tax_amount <- Tradewinds.Economy.calculate_tax_for_port(cost, warehouse.port_id),
           {:ok, _company} <-
             Tradewinds.Companies.record_transaction(
               warehouse.company_id,
               -cost,
               "warehouse_upgrade",
               "warehouse",
               warehouse.id,
               now
             ),
           {:ok, _company} <-
             (if tax_amount > 0 do
                Tradewinds.Companies.record_transaction(
                  warehouse.company_id,
                  -tax_amount,
                  :tax,
                  :warehouse,
                  warehouse.id,
                  now,
                  meta: %{base_amount: cost, port_id: warehouse.port_id}
                )
              else
                {:ok, :no_tax}
              end) do
        warehouse
        |> Warehouse.update_tier_changeset(%{
          level: warehouse.level + 1,
          capacity: warehouse.capacity + 1000
        })
        |> Repo.update()
      end
    end)
  end

  @doc """
  Downgrades a warehouse to the previous tier, decreasing its level and capacity.
  Fails if the resulting capacity would be less than the currently stored inventory.
  """
  def shrink_warehouse(warehouse_id) do
    Repo.transact(fn ->
      with {:ok, warehouse} <- fetch_warehouse_for_update(warehouse_id),
           {:ok, inventory_total} <- current_inventory_total(warehouse_id),
           :ok <- check_can_shrink(warehouse, inventory_total) do
        warehouse
        |> Warehouse.update_tier_changeset(%{
          level: warehouse.level - 1,
          capacity: warehouse.capacity - 1000
        })
        |> Repo.update()
      end
    end)
  end

  # Validates that a warehouse is eligible to be downgraded.
  defp check_can_shrink(warehouse, inventory_total) do
    cond do
      warehouse.level <= 1 ->
        {:error, :already_minimum_tier}

      inventory_total > warehouse.capacity - 1000 ->
        {:error, :capacity_exceeded_if_shrunk}

      true ->
        :ok
    end
  end

  @doc """
  Retrieves a warehouse by its ID.
  """
  def fetch_warehouse(id) do
    Repo.get(Warehouse, id)
    |> Repo.ok_or(:warehouse_not_found)
  end

  @doc """
  Retrieves a specific company's warehouse at a given port.
  """
  def fetch_warehouse(company_id, port_id) do
    Warehouse
    |> where(company_id: ^company_id, port_id: ^port_id)
    |> Repo.one()
    |> Repo.ok_or(:warehouse_not_found)
  end

  # Retrieves and locks a warehouse for transaction safety.
  defp fetch_warehouse_for_update(warehouse_id) do
    Warehouse
    |> where(id: ^warehouse_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:warehouse_not_found)
  end

  # Ensures the warehouse has enough remaining capacity for the new quantity.
  defp check_capacity(warehouse, current_total, quantity) do
    if current_total + quantity > warehouse.capacity do
      {:error, :capacity_exceeded}
    else
      :ok
    end
  end

  @doc """
  Gets the total quantity of all inventory currently stored in the given warehouse.
  """
  def current_inventory_total(warehouse_id) do
    query =
      from w in Warehouse,
        where: w.id == ^warehouse_id,
        left_join: i in WarehouseInventory,
        on: i.warehouse_id == w.id,
        group_by: w.id,
        select: {w.id, sum(i.quantity)}

    case Repo.one(query) do
      {_id, sum} -> {:ok, sum || 0}
      nil -> {:error, :warehouse_not_found}
    end
  end

  @doc """
  Removes a specified quantity of a good from a warehouse.
  Deletes the inventory record entirely if the quantity drops to zero.
  """
  def remove_cargo(warehouse_id, good_id, quantity) when quantity > 0 do
    Repo.transact(fn ->
      with {:ok, inventory} <- fetch_inventory_for_update(warehouse_id, good_id),
           :ok <- check_sufficient_inventory(inventory, quantity) do
        if inventory.quantity == quantity do
          Repo.delete(inventory)
        else
          inventory
          |> WarehouseInventory.update_quantity_changeset(%{
            quantity: inventory.quantity - quantity
          })
          |> Repo.update()
        end
      end
    end)
  end

  # Retrieves and locks a specific inventory record for transaction safety.
  defp fetch_inventory_for_update(warehouse_id, good_id) do
    WarehouseInventory
    |> where(warehouse_id: ^warehouse_id, good_id: ^good_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:inventory_not_found)
  end

  # Ensures the warehouse actually holds enough of the requested good.
  defp check_sufficient_inventory(inventory, quantity) do
    if inventory.quantity < quantity do
      {:error, :insufficient_inventory}
    else
      :ok
    end
  end

  # Stub: Rent a new warehouse for a company at a port.
  def rent_warehouse(%Scope{} = _scope, _company_id, _port_id) do
  end

  # Stub: List all warehouses owned by a company.
  def list_warehouses(%Scope{} = _scope, _company_id) do
  end

  # Stub: Move goods from a ship to a warehouse.
  def deposit(%Scope{} = _scope, _warehouse_id, _good_id, _quantity) do
  end

  # Stub: Move goods from a warehouse to a ship.
  def withdraw(%Scope{} = _scope, _warehouse_id, _good_id, _quantity) do
  end
end
