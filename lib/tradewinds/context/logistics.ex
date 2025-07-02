defmodule Tradewinds.Logistics do
  @moduledoc """
  The Logistics context, responsible for ship movement and management.
  """
  alias Tradewinds.Repo
  alias Tradewinds.LogisticsRepo
  alias Tradewinds.Companies

  def create_warehouse(company, port, initial_capacity) do
    with :ok <- Companies.check_presence_in_port(company, port) do
      LogisticsRepo.create_warehouse(company, port, initial_capacity)
    end
  end

  def change_warehouse_capacity(warehouse, new_capacity) do
    warehouse = Repo.preload(warehouse, [:company, :port])

    with :ok <- Companies.check_presence_in_port(warehouse.company, warehouse.port) do
      LogisticsRepo.update_warehouse_capacity(warehouse, new_capacity)
    end
  end

  def set_sail(ship, destination_port) do
    with {:ok, route} <- LogisticsRepo.find_route(ship.port_id, destination_port.id),
         arriving_at <- calculate_arrival(route.distance, ship.speed) do
      LogisticsRepo.set_ship_to_sail(ship, route, arriving_at)
    end
  end

  defp calculate_arrival(distance, speed) do
    # For now, a simple calculation. This can be expanded later.
    travel_time = round(distance / speed * 10)

    DateTime.utc_now()
    |> DateTime.add(travel_time, :second)
    |> DateTime.truncate(:second)
  end
end
