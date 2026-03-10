defmodule TradewindsWeb.ShipyardJSON do
  def show(%{shipyard: shipyard}) do
    %{data: data(shipyard)}
  end

  def data(shipyard) do
    %{
      id: shipyard.id,
      port_id: shipyard.port_id,
      inserted_at: shipyard.inserted_at,
      updated_at: shipyard.updated_at
    }
  end

  def inventory(%{inventory: inventory}) do
    %{data: for(inv <- inventory, do: inventory_data(inv))}
  end

  def inventory_data(inv) do
    %{
      id: inv.id,
      shipyard_id: inv.shipyard_id,
      ship_type_id: inv.ship_type_id,
      ship_id: inv.ship_id,
      cost: inv.cost,
      inserted_at: inv.inserted_at,
      updated_at: inv.updated_at
    }
  end
end
