defmodule Tradewinds.Logistics do
  @moduledoc """
  The Logistics context, responsible for ship movement and management.
  """

  alias Tradewinds.LogisticsRepo
  alias Tradewinds.Repo
  alias Tradewinds.Schema.Ship
  import Ecto.Query

  def set_sail(ship, destination_port) do
    with {:ok, route} <- LogisticsRepo.find_route(ship.port_id, destination_port.id),
         arriving_at <- calculate_arrival(route.distance, ship.speed) do
      ship
      |> Ship.changeset(%{
        state: :at_sea,
        port_id: nil,
        route_id: route.id,
        arriving_at: arriving_at
      })
      |> Repo.update()
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