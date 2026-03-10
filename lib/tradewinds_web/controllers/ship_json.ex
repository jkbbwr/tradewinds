defmodule TradewindsWeb.ShipJSON do
  def index(%{page: page}) do
    %{
      data: for(ship <- page.entries, do: data(ship)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  def show(%{ship: ship}) do
    %{data: data(ship)}
  end

  def data(ship) do
    %{
      id: ship.id,
      name: ship.name,
      status: ship.status,
      arriving_at: ship.arriving_at,
      company_id: ship.company_id,
      ship_type_id: ship.ship_type_id,
      port_id: ship.port_id,
      route_id: ship.route_id,
      inserted_at: ship.inserted_at,
      updated_at: ship.updated_at
    }
  end
end
