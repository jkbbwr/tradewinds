defmodule Tradewinds.FleetTest do
  use Tradewinds.DataCase

  alias Tradewinds.Fleet
  alias Tradewinds.Scope

  describe "ships" do
    test "fetch_ship/1 returns the ship" do
      ship = insert(:ship)
      assert {:ok, fetched_ship} = Fleet.fetch_ship(ship.id)
      assert fetched_ship.id == ship.id
    end

    test "fetch_ship/1 returns error if not found" do
      assert {:error, :ship_not_found} = Fleet.fetch_ship(Ecto.UUID.generate())
    end

    test "rename_ship/3 renames the ship if authorized" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      ship = insert(:ship, company: company, name: "Old Name")

      # Correctly construct scope
      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:ok, updated_ship} = Fleet.rename_ship(scope, ship.id, "New Name")
      assert updated_ship.name == "New Name"
    end

    test "rename_ship/3 fails if unauthorized" do
      player = insert(:player)
      other_company = insert(:company)
      ship = insert(:ship, company: other_company)

      # Not authorized
      scope = Scope.for(player: player, company_ids: [])

      assert {:error, :unauthorized} = Fleet.rename_ship(scope, ship.id, "New Name")
    end

    test "assign_ship/2 updates the company_id" do
      ship = insert(:ship)
      new_company = insert(:company)

      assert {:ok, updated_ship} = Fleet.assign_ship(ship.id, new_company.id)
      assert updated_ship.company_id == new_company.id
    end

    test "transfer_ship/3 transfers ship if authorized" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, company: company, player: player)
      ship = insert(:ship, company: company)
      new_company = insert(:company)

      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:ok, updated_ship} = Fleet.transfer_ship(scope, ship.id, new_company.id)
      assert updated_ship.company_id == new_company.id
    end

    test "transfer_ship/3 fails if unauthorized" do
      player = insert(:player)
      other_company = insert(:company)
      ship = insert(:ship, company: other_company)
      new_company = insert(:company)

      scope = Scope.for(player: player, company_ids: [])

      assert {:error, :unauthorized} = Fleet.transfer_ship(scope, ship.id, new_company.id)
    end
  end
end
