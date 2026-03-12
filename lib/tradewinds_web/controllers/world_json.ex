defmodule TradewindsWeb.WorldJSON do
  def ports(%{page: page}) do
    %{
      data: for(port <- page.entries, do: port_data(port)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  def port(%{port: port}) do
    %{data: port_data(port)}
  end

  def goods(%{goods: goods}) do
    %{data: for(good <- goods, do: good_data(good))}
  end

  def good(%{good: good}) do
    %{data: good_data(good)}
  end

  def ship_types(%{ship_types: ship_types}) do
    %{data: for(ship_type <- ship_types, do: ship_type_data(ship_type))}
  end

  def ship_type(%{ship_type: ship_type}) do
    %{data: ship_type_data(ship_type)}
  end

  def routes(%{page: page}) do
    %{
      data: for(route <- page.entries, do: route_data(route)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  def route(%{route: route}) do
    %{data: route_data(route)}
  end

  defp port_data(port) do
    data = %{
      id: port.id,
      name: port.name,
      shortcode: port.shortcode,
      country_id: port.country_id,
      is_hub: port.is_hub,
      tax_rate_bps: port.tax_rate_bps,
      inserted_at: port.inserted_at,
      updated_at: port.updated_at
    }

    data
    |> maybe_put_traders(port)
    |> maybe_put_routes(port)
  end

  defp maybe_put_traders(data, %{traders: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_put_traders(data, %{traders: traders}) do
    Map.put(data, :traders, Enum.map(traders, &trader_data/1))
  end

  defp maybe_put_routes(data, %{outgoing_routes: %Ecto.Association.NotLoaded{}}), do: data

  defp maybe_put_routes(data, %{outgoing_routes: routes}) do
    Map.put(data, :outgoing_routes, Enum.map(routes, &route_data/1))
  end

  defp trader_data(trader) do
    %{
      id: trader.id,
      name: trader.name,
      inserted_at: trader.inserted_at,
      updated_at: trader.updated_at
    }
  end

  defp good_data(good) do
    %{
      id: good.id,
      name: good.name,
      description: good.description,
      category: good.category,
      inserted_at: good.inserted_at,
      updated_at: good.updated_at
    }
  end

  defp ship_type_data(ship_type) do
    %{
      id: ship_type.id,
      name: ship_type.name,
      description: ship_type.description,
      capacity: ship_type.capacity,
      speed: ship_type.speed,
      base_price: ship_type.base_price,
      upkeep: ship_type.upkeep,
      passengers: ship_type.passengers,
      inserted_at: ship_type.inserted_at,
      updated_at: ship_type.updated_at
    }
  end

  defp route_data(route) do
    %{
      id: route.id,
      distance: route.distance,
      from_id: route.from_id,
      to_id: route.to_id,
      inserted_at: route.inserted_at,
      updated_at: route.updated_at
    }
  end
end
