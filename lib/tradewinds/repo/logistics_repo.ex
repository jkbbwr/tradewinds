defmodule Tradewinds.LogisticsRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.Route
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Warehouse
  alias Tradewinds.Schema.WarehouseInventory
  import Ecto.Query

  def create_warehouse(company, port, initial_capacity) do
    %Warehouse{}
    |> Warehouse.create_changeset(%{
      company_id: company.id,
      port_id: port.id,
      capacity: initial_capacity
    })
    |> Repo.insert()
  end

  def fetch_warehouse_inventory(warehouse) do
    Repo.preload(warehouse, :inventory)
  end

  def update_warehouse_capacity(warehouse, new_capacity) do
    warehouse
    |> Warehouse.update_capacity_changeset(new_capacity)
    |> Repo.update()
  end

  def find_route(origin_id, destination_id) do
    from(r in Route,
      where:
        (r.from_id == ^origin_id and r.to_id == ^destination_id) or
          (r.from_id == ^destination_id and r.to_id == ^origin_id)
    )
    |> Repo.one()
    |> Repo.ok_or("route not found between #{origin_id} and #{destination_id}")
  end

  def set_ship_to_sail(ship, route, arriving_at) do
    ship
    |> Ship.transit_changeset(route, arriving_at)
    |> Repo.update()
  end
end
