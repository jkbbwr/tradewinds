defmodule TradewindsWeb.WorldJSON do
  def ports(%{ports: ports}) do
    %{data: for(port <- ports, do: port_data(port))}
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

  def route(%{route: route}) do
    %{data: route_data(route)}
  end

  defp port_data(port) do
    %{
      id: port.id,
      name: port.name,
      shortcode: port.shortcode,
      country_id: port.country_id,
      is_hub: port.is_hub,
      tax_rate_bps: port.tax_rate_bps,
      inserted_at: port.inserted_at,
      updated_at: port.updated_at
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
