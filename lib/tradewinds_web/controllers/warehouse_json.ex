defmodule TradewindsWeb.WarehouseJSON do
  def index(%{warehouses: warehouses}) do
    %{data: for(warehouse <- warehouses, do: data(warehouse))}
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
