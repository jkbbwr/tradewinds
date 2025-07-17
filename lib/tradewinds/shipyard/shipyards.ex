defmodule Tradewinds.Shipyards do
  alias Tradewinds.Repo
  alias Tradewinds.Shipyard
  alias Tradewinds.Shipyard.ShipyardInventory
  alias Tradewinds.Ships
  import Ecto.Query

  def create_shipyard(port_id, max_ships, production_type, production_count) do
    %Shipyard{}
    |> Shipyard.create_changeset(%{
      port_id: port_id,
      max_ships: max_ships,
      production_type: production_type,
      production_count: production_count
    })
    |> Repo.insert()
  end

  def list_shipyards do
    Repo.all(Shipyard)
  end

  def produce_ships(shipyard) do
    Repo.transaction(fn ->
      current_ship_count = get_shipyard_ship_count(shipyard)
      remaining_capacity = shipyard.max_ships - current_ship_count
      ships_to_produce = min(shipyard.production_count, remaining_capacity)

      if ships_to_produce > 0 do
        for _ <- 1..ships_to_produce do
          with {:ok, ship} <- Ships.create_ship(shipyard.production_type) do
            # TODO: Determine a real cost
            add_ship_to_inventory(shipyard, ship, 10000)
          end
        end
      end
    end)
  end

  defp get_shipyard_ship_count(shipyard) do
    from(si in ShipyardInventory, where: si.shipyard_id == ^shipyard.id)
    |> Repo.aggregate(:count, :id)
  end

  defp add_ship_to_inventory(shipyard, ship, cost) do
    %ShipyardInventory{}
    |> ShipyardInventory.create_changeset(%{
      shipyard_id: shipyard.id,
      ship_id: ship.id,
      cost: cost
    })
    |> Repo.insert()
  end
end
