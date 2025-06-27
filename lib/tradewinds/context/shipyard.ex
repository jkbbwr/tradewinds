defmodule Tradewinds.Shipyard do
  @moduledoc """
  The Shipyard context, responsible for building and transacting ships.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.ShipyardInventory
  alias Tradewinds.Schema.Company
  alias Tradewinds.Companies

  def create_unowned_ship(shipyard, ship_attrs) do
    Repo.transact(fn ->
      ship_params = Map.take(ship_attrs, [:name, :state, :type, :capacity, :speed, :port_id])

      with {:ok, ship} <- Ship.changeset(%Ship{}, ship_params) |> Repo.insert(),
           {:ok, inventory} <-
             ShipyardInventory.changeset(%ShipyardInventory{}, %{
               shipyard_id: shipyard.id,
               ship_id: ship.id,
               cost: ship_attrs.cost
             })
             |> Repo.insert() do
        {:ok, %{ship: ship, inventory: inventory}}
      end
    end)
  end

  def purchase_ship(company, shipyard_inventory) do
    Repo.transact(fn ->
      ship = Repo.get!(Ship, shipyard_inventory.ship_id)
      company = Repo.get!(Company, company.id)

      if company.treasury >= shipyard_inventory.cost do
        ship_changeset = Ship.changeset(ship, %{company_id: company.id})

        with {:ok, updated_company} <- Companies.debit_treasury(company, shipyard_inventory.cost),
             {:ok, updated_ship} <- Repo.update(ship_changeset),
             {:ok, _} <- Repo.delete(shipyard_inventory) do
          {:ok, %{company: updated_company, ship: updated_ship}}
        else
          _ -> {:error, "Failed to purchase ship"}
        end
      else
        {:error, "Not enough funds to purchase ship"}
      end
    end)
  end
end
