defmodule Tradewinds.Logistics do
  @moduledoc """
  The Logistics context, responsible for ship movement and management.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Route
  import Ecto.Query

  def set_sail(ship, destination_port) do
    with {:ok, route} <- find_route(ship.port_id, destination_port.id),
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

  defp find_route(origin_id, destination_id) do
    route =
      from(r in Route,
        where:
          (r.from_id == ^origin_id and r.to_id == ^destination_id) or
            (r.from_id == ^destination_id and r.to_id == ^origin_id)
      )
      |> Repo.one()

    if route, do: {:ok, route}, else: {:error, :route_not_found}
  end

  defp calculate_arrival(distance, speed) do
    # For now, a simple calculation. This can be expanded later.
    travel_time = round(distance / speed * 10)

    DateTime.utc_now()
    |> DateTime.add(travel_time, :second)
    |> DateTime.truncate(:second)
  end
end
