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

  def transit_logs(%{page: page}) do
    %{
      data: for(log <- page.entries, do: transit_log_data(log)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  def inventory(%{cargo: cargo}) do
    %{
      data: for(item <- cargo, do: cargo_data(item))
    }
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

  def transit_log_data(log) do
    %{
      id: log.id,
      departed_at: log.departed_at,
      arrived_at: log.arrived_at,
      ship_id: log.ship_id,
      route_id: log.route_id
    }
  end

  def cargo_data(item) do
    %{
      good_id: item.good_id,
      quantity: item.quantity
    }
  end
end
