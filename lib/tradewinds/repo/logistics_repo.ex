defmodule Tradewinds.LogisticsRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.Route
  import Ecto.Query

  def find_route(origin_id, destination_id) do
    route =
      from(r in Route,
        where:
          (r.from_id == ^origin_id and r.to_id == ^destination_id) or
            (r.from_id == ^destination_id and r.to_id == ^origin_id)
      )
      |> Repo.one()

    if route, do: {:ok, route}, else: {:error, :route_not_found}
  end
end
