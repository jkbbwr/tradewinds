defmodule Tradewinds.Shipyards do
  @moduledoc """
  The Shipyards context.
  Handles ship construction, shipyard inventory, and player ship purchasing.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Companies
  alias Tradewinds.Fleet
  alias Tradewinds.Shipyards.Shipyard
  alias Tradewinds.Shipyards.Inventory
  alias Tradewinds.Scope

  @doc """
  Fetches a shipyard by its ID.
  """
  def fetch_shipyard(id) do
    Repo.get(Shipyard, id)
    |> Repo.ok_or(:shipyard_not_found)
  end

  @doc """
  Fetches the shipyard associated with a specific port.
  """
  def fetch_shipyard_for_port(port) do
    Repo.get_by(Shipyard, port_id: port.id)
    |> Repo.ok_or(:shipyard_not_found)
  end

  @doc """
  Fetches all available inventory (unowned ships) currently for sale at a shipyard.
  """
  def fetch_shipyard_inventory(shipyard_id) do
    query =
      from s in Shipyard,
        where: s.id == ^shipyard_id,
        left_join: i in assoc(s, :inventory),
        select: i

    Repo.all(query)
    |> Repo.ok_or(:shipyard_not_found)
  end

  @doc """
  Checks if a shipyard has at least one ship of a specific type in stock.
  Returns boolean or an error if the shipyard doesn't exist.
  """
  def has_stock?(shipyard_id, ship_type_id) do
    query =
      from s in Shipyard,
        where: s.id == ^shipyard_id,
        left_join: inv in Inventory,
        on: inv.shipyard_id == s.id and inv.ship_type_id == ^ship_type_id,
        select: not is_nil(inv.id),
        limit: 1

    case Repo.one(query) do
      nil -> {:error, :shipyard_not_found}
      has_stock -> has_stock
    end
  end

  @doc """
  Atomically purchases a ship from a shipyard, assigning it to the company 
  and deducting the cost from the company's treasury.
  """
  def purchase_ship(%Scope{} = scope, company_id, shipyard_id, ship_type_id) do
    Repo.transact(fn ->
      with :ok <- Scope.authorizes?(scope, company_id),
           {:ok, inventory} <- fetch_inventory_for_update(shipyard_id, ship_type_id),
           {:ok, ship} <- Fleet.assign_ship(inventory.ship_id, company_id),
           {:ok, _inventory} <- Repo.delete(inventory),
           {:ok, _company} <-
             Companies.record_transaction(
               company_id,
               -inventory.cost,
               :ship_purchase,
               :ship,
               inventory.ship_id,
               DateTime.utc_now()
             ) do
        {:ok, ship}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  # Fetches and locks an inventory record for transaction safety during a purchase.
  defp fetch_inventory_for_update(shipyard_id, ship_type_id) do
    Inventory
    |> where(shipyard_id: ^shipyard_id, ship_type_id: ^ship_type_id)
    |> limit(1)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:inventory_not_found)
  end

  @doc """
  Seeds a newly built, unowned ship into a shipyard's inventory.
  """
  def create_ship(shipyard_id, ship_type_id, ship_id, cost) do
    %Inventory{}
    |> Inventory.create_changeset(%{
      shipyard_id: shipyard_id,
      ship_type_id: ship_type_id,
      ship_id: ship_id,
      cost: cost
    })
    |> Repo.insert()
  end

  @doc """
  Produces ships at a specific shipyard to maintain stock levels.
  Ensures a minimum stock of 2 for each ship type.
  Bigger ships (higher capacity) take proportionally longer to build based on a weekly probability roll.
  """
  def produce_ships(shipyard_id) do
    with {:ok, shipyard} <- fetch_shipyard(shipyard_id),
         ship_types <- Repo.all(Tradewinds.World.ShipType),
         {:ok, result} <-
           Repo.transact(fn ->
             Enum.each(ship_types, fn type ->
               count =
                 Inventory
                 |> where(shipyard_id: ^shipyard.id, ship_type_id: ^type.id)
                 |> Repo.aggregate(:count, :id)

               # Calculate production probability. Base capacity of 100 has a 100% chance per week.
               # Larger ships like a 200 capacity Galleon have a 50% chance per week (~2 weeks).
               probability = min(1.0, 100.0 / max(type.capacity, 1))

               if count < 2 and :rand.uniform() <= probability do
                 build_ship_for_inventory(shipyard, type)
               end
             end)

             {:ok, :produced}
           end) do
      {:ok, result}
    end
  end

  defp build_ship_for_inventory(shipyard, ship_type) do
    ship_name = "#{ship_type.name} - #{Ecto.UUID.generate() |> String.slice(0..7)}"

    with {:ok, ship} <-
           %Tradewinds.Fleet.Ship{}
           |> Tradewinds.Fleet.Ship.create_changeset(%{
             name: ship_name,
             status: :docked,
             port_id: shipyard.port_id,
             ship_type_id: ship_type.id,
             company_id: nil
           })
           |> Repo.insert() do
      create_ship(shipyard.id, ship_type.id, ship.id, ship_type.base_price)
    end
  end
end
