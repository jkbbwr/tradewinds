defmodule Tradewinds.ShipyardTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.Shipyard

  describe "create_unowned_ship/2" do
    test "creates an unowned ship in a shipyard" do
      port = insert(:port)
      shipyard = insert(:shipyard, port: port)

      ship_attrs = %{
        name: "The Flying Dutchman",
        state: :in_port,
        type: :cutter,
        capacity: 100,
        speed: 10,
        port_id: port.id,
        cost: 10_000
      }

      {:ok, result} = Shipyard.create_unowned_ship(shipyard, ship_attrs)

      assert result.ship.name == "The Flying Dutchman"
      assert result.ship.company_id == nil
      assert result.inventory.cost == 10_000
      assert result.inventory.shipyard_id == shipyard.id
    end
  end

  describe "purchase_ship/2" do
    test "allows a company to purchase a ship" do
      port = insert(:port)
      company = insert(:company, treasury: 20_000, home_port_id: port.id)
      shipyard = insert(:shipyard, port: port)
      ship = insert(:ship)

      shipyard_inventory =
        insert(:shipyard_inventory, shipyard: shipyard, ship: ship, cost: 10_000)

      {:ok, purchased_ship} = Shipyard.purchase_ship(company, shipyard_inventory)

      assert purchased_ship.company_id == company.id
    end

    test "prevents a company from purchasing a ship with insufficient funds" do
      port = insert(:port)
      company = insert(:company, treasury: 5_000, home_port_id: port.id)
      shipyard = insert(:shipyard, port: port)
      ship = insert(:ship)

      shipyard_inventory =
        insert(:shipyard_inventory, shipyard: shipyard, ship: ship, cost: 10_000)

      assert Shipyard.purchase_ship(company, shipyard_inventory) == {:error, :insufficient_funds}
    end

    test "prevents a company from purchasing a ship with no presence in the port" do
      company = insert(:company, treasury: 20_000)
      shipyard = insert(:shipyard)
      ship = insert(:ship)

      shipyard_inventory =
        insert(:shipyard_inventory, shipyard: shipyard, ship: ship, cost: 10_000)

      assert Shipyard.purchase_ship(company, shipyard_inventory) == {:error, :no_presence_in_port}
    end
  end
end
