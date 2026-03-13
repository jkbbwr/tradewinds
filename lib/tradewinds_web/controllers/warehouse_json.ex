defmodule TradewindsWeb.WarehouseJSON do
  def index(%{page: page}) do
    %{
      data: for(warehouse <- page.entries, do: data(warehouse)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  def show(%{warehouse: warehouse}) do
    %{data: data(warehouse)}
  end

  def data(warehouse) do
    %{
      id: warehouse.id,
      level: warehouse.level,
      capacity: warehouse.capacity,
      port_id: warehouse.port_id,
      company_id: warehouse.company_id,
      inserted_at: warehouse.inserted_at,
      updated_at: warehouse.updated_at
    }
  end

  def inventory(%{page: page}) do
    %{
      data: for(inv <- page.entries, do: inventory_data(inv)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  defp inventory_data(inv) do
    %{
      id: inv.id,
      warehouse_id: inv.warehouse_id,
      good_id: inv.good_id,
      quantity: inv.quantity
    }
  end
end
