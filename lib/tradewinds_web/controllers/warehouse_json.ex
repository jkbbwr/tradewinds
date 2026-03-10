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
end
