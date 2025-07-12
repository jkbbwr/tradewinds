defmodule Tradewinds.Ships do
  @moduledoc """
  The Ships context, responsible for ship movement and management.
  """
  alias Tradewinds.World
  alias Tradewinds.Repo
  alias Tradewinds.Ships.Ship
  alias Tradewinds.Ships.ShipInventory
  import Ecto.Query

  def set_sail(ship, destination_port) do
    with {:ok, route} <- World.find_route(ship.port_id, destination_port.id),
         arriving_at <- calculate_arrival(route.distance, ship.speed) do
      set_ship_to_sail(ship, route, arriving_at)
    end
  end

  defp calculate_arrival(distance, speed) do
    # For now, a simple calculation. This can be expanded later.
    travel_time = round(distance / speed * 10)

    DateTime.utc_now()
    |> DateTime.add(travel_time, :second)
    |> DateTime.truncate(:second)
  end

  defp set_ship_to_sail(ship, route, arriving_at) do
    ship
    |> Ship.transit_changeset(route, arriving_at)
    |> Repo.update()
  end

  def load(ship, item, amount) do
    current_weight = get_ship_total_cargo(ship.id)
    new_weight = amount

    if current_weight + new_weight > ship.capacity do
      {:error, :not_enough_capacity}
    else
      Repo.insert!(
        %ShipInventory{ship_id: ship.id, item_id: item.id, amount: amount},
        on_conflict: [inc: [amount: amount]],
        conflict_target: [:ship_id, :item_id]
      )

      {:ok, :loaded}
    end
  end

  def unload(ship, item, amount) do
    Repo.transact(fn ->
      with {:ok, inventory} <- fetch_inventory_by_item_id(ship, item) do
        cond do
          inventory.amount == amount ->
            Repo.delete(inventory)

          inventory.amount < amount ->
            {:error, :not_enough_inventory}

          inventory.amount > amount ->
            inventory
            |> ShipInventory.update_amount_changeset(inventory.amount - amount)
            |> Repo.update()
        end
      end
    end)
  end

  defp fetch_inventory_by_item_id(ship, item) do
    Repo.get_by(ShipInventory, ship_id: ship.id, item_id: item.id)
    |> Repo.ok_or(:ship_inventory_not_found)
  end

  def get_ship_total_cargo(ship_id) do
    from(si in Tradewinds.Ships.ShipInventory,
      where: si.ship_id == ^ship_id,
      select: sum(si.amount)
    )
    |> Repo.one()
    |> then(&(&1 || 0))
  end
end
