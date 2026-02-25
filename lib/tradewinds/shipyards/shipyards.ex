defmodule Tradewinds.Shipyards do
  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Companies
  alias Tradewinds.Fleet
  alias Tradewinds.Shipyards.Shipyard
  alias Tradewinds.Shipyards.Inventory
  alias Tradewinds.Scope

  def fetch_shipyard(id) do
    Repo.get(Shipyard, id) |> Repo.ok_or(:shipyard_not_found)
  end

  def fetch_shipyard_inventory(shipyard_id) do
    query =
      from s in Shipyard,
        where: s.id == ^shipyard_id,
        left_join: i in assoc(s, :inventory),
        select: i

    Repo.all(query)
    |> Repo.ok_or(:shipyard_not_found)
  end

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
               Tradewinds.get_tick()
             ) do
        {:ok, ship}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp fetch_inventory_for_update(shipyard_id, ship_type_id) do
    Inventory
    |> where(shipyard_id: ^shipyard_id, ship_type_id: ^ship_type_id)
    |> limit(1)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:inventory_not_found)
  end

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
end
