defmodule Tradewinds.Shipyard do
  @moduledoc """
  The Shipyard context, responsible for building and transacting ships.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.ShipyardInventory
  alias Tradewinds.Schema.Shipyard
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
      with {:ok, ship} <- Repo.fetch(Ship, shipyard_inventory.ship_id),
           {:ok, company} <- Repo.fetch(Company, company.id),
           {:ok, shipyard} <- Repo.fetch(Shipyard, shipyard_inventory.shipyard_id),
           :ok <- Companies.check_presence_in_port(company, shipyard.port_id),
           :ok <- Companies.check_sufficient_funds(company, shipyard_inventory.cost),
           {:ok, updated_ship} <- complete_purchase(company, ship, shipyard_inventory) do
        {:ok, updated_ship}
      else
        {:error, {:not_found, Ship}} ->
          {:error, {:not_found, "Couldn't find ship with id #{shipyard_inventory.ship_id}"}}

        {:error, {:not_found, Company}} ->
          {:error, {:not_found, "Couldn't find company with id #{company.id}"}}
      end
    end)
  end

  defp complete_purchase(company, ship, shipyard_inventory) do
    ship_changeset = Ship.changeset(ship, %{company_id: company.id})

    with {:ok, _updated_company} <- Companies.debit_treasury(company, shipyard_inventory.cost),
         {:ok, updated_ship} <- Repo.update(ship_changeset),
         {:ok, _} <- Repo.delete(shipyard_inventory) do
      {:ok, updated_ship}
    end
  end
end
