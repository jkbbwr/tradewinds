defmodule Tradewinds.Shipyard do
  @moduledoc """
  The Shipyard context, responsible for building and transacting ships.
  """

  alias Tradewinds.Repo
  alias Tradewinds.ShipyardRepo
  alias Tradewinds.CompanyRepo
  alias Tradewinds.Companies

  def create_unowned_ship(shipyard, ship_attrs, cost) do
    Repo.transact(fn ->
      with {:ok, ship} <- ShipyardRepo.create_ship(ship_attrs),
           {:ok, inventory} <- ShipyardRepo.create_inventory(shipyard, ship, cost) do
        {:ok, %{ship: ship, inventory: inventory}}
      end
    end)
  end

  def purchase_ship(company, shipyard_inventory) do
    shipyard_inventory = shipyard_inventory |> Repo.preload([:ship, shipyard: [:port]])
    shipyard = shipyard_inventory.shipyard
    ship = shipyard_inventory.ship

    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, shipyard.port),
           :ok <- Companies.check_sufficient_funds(company, shipyard_inventory.cost),
           {:ok, _company} <- CompanyRepo.debit_treasury(company, shipyard_inventory.cost),
           {:ok, _} <- ShipyardRepo.delete_inventory(shipyard_inventory) do
        ShipyardRepo.update_company_for_ship(company, ship)
      end
    end)
  end
end
