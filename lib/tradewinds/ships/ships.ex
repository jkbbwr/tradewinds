defmodule Tradewinds.Ships do
  @moduledoc """
  The Ships context, responsible for ship movement and management.
  """
  alias Tradewinds.World
  alias Tradewinds.Repo
  alias Tradewinds.Ships.Ship
  alias Tradewinds.Ships.ShipInventory
  alias Tradewinds.Ships.Passenger
  alias Tradewinds.Companies
  import Ecto.Query

  def create_ship(type) do
    attrs =
      case type do
        :cutter ->
          %{
            name: "Cutter",
            state: :in_port,
            type: :cutter,
            capacity: 100,
            speed: 10,
            max_passengers: 4
          }
      end

    %Ship{}
    |> Ship.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Sets a ship to sail to a destination port.
  """
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

  @doc """
  Embarks a passenger onto a ship.
  """
  def embark_passenger(ship, passenger_id, type) do
    Repo.transaction(fn ->
      ship = Repo.preload(ship, :passengers)

      with :ok <- check_has_passenger_space(ship),
           {:ok, nil} <- assign_passenger_to_ship(type, passenger_id, ship.id) do
        %Passenger{}
        |> Passenger.create_changeset(%{
          ship_id: ship.id,
          passenger_id: passenger_id,
          type: type
        })
        |> Repo.insert()
      end
    end)
  end

  defp check_has_passenger_space(ship) do
    if length(ship.passengers) < ship.max_passengers do
      :ok
    else
      {:error, :ship_is_full}
    end
  end

  defp assign_passenger_to_ship(type, passenger_id, ship_id) do
    case type do
      :company_agent ->
        agent = Companies.get_agent(passenger_id)
        Companies.assign_agent_to_ship(agent, ship_id)

      _ ->
        {:ok, nil}
    end
  end

  defp assign_passenger_location(passenger, port_id) do
    case passenger.type do
      :company_agent ->
        agent = Companies.get_agent(passenger.passenger_id)
        Companies.assign_agent_to_port(agent, port_id)

      _ ->
        {:ok, nil}
    end
  end

  @doc """
  Disembarks a passenger from a ship.
  """
  def disembark_passenger(ship, passenger_id) do
    Repo.transaction(fn ->
      with {:ok, passenger} <- fetch_passenger(ship.id, passenger_id),
           :ok <- assign_passenger_location(passenger, ship.port_id) do
        Repo.delete(passenger)
      end
    end)
  end

  def fetch_passenger(ship_id, passenger_id) do
    Repo.get_by(Passenger, ship_id: ship_id, passenger_id: passenger_id)
    |> Repo.ok_or(:passenger_not_found)
  end

  @doc """
  Loads a specific amount of an item onto a ship.
  """
  def load(ship, item, amount) do
    current_weight = get_ship_total_cargo(ship.id)
    new_weight = amount

    if current_weight + new_weight > ship.capacity do
      {:error, :not_enough_capacity}
    else
      Repo.insert(
        %ShipInventory{ship_id: ship.id, item_id: item.id, amount: amount},
        on_conflict: [inc: [amount: amount]],
        conflict_target: [:ship_id, :item_id]
      )

      {:ok, :loaded}
    end
  end

  @doc """
  Unloads a specific amount of an item from a ship.
  """
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

  @doc """
  Returns the total cargo weight of a ship.
  """
  def get_ship_total_cargo(ship_id) do
    from(si in Tradewinds.Ships.ShipInventory,
      where: si.ship_id == ^ship_id,
      select: sum(si.amount)
    )
    |> Repo.one()
    |> then(&(&1 || 0))
  end

  @doc """
  Returns a list of all ships that are currently at sea.
  """
  def list_at_sea_ships do
    from(s in Ship, where: s.state == :at_sea)
    |> Repo.all()
  end

  @doc """
  Updates a ship's state to indicate it has arrived in port.
  """
  def ship_arrived(%Ship{} = ship) do
    ship = Repo.preload(ship, :route)
    destination_port_id = ship.route.end_port_id

    from(s in Ship, where: s.id == ^ship.id and s.state == :at_sea)
    |> Repo.update_all(
      set: [
        state: :in_port,
        port_id: destination_port_id,
        route_id: nil,
        arriving_at: nil,
        updated_at: DateTime.utc_now()
      ]
    )
  end
end
