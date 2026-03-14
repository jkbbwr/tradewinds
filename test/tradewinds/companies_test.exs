defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Companies
  alias Tradewinds.Companies.Company
  alias Tradewinds.Scope

  describe "companies" do
    test "create/5 creates a company and assigns the player as director" do
      player = insert(:player)
      port = insert(:port)
      scope = Scope.for(player: player)

      assert {:ok, company} =
               Companies.create(scope, "East India Company", "EIC", port.id, 10000)

      assert company.name == "East India Company"
      assert company.ticker == "EIC"
      assert company.treasury == 10000
      assert company.home_port_id == port.id

      # Verify directorship
      company_ids = Companies.list_player_company_ids(player)
      assert company.id in company_ids
    end

    test "create/5 automatically uppercases the ticker" do
      player = insert(:player)
      port = insert(:port)
      scope = Scope.for(player: player)

      assert {:ok, company} = Companies.create(scope, "Lowercase Co", "low", port.id)
      assert company.ticker == "LOW"
    end

    test "create/5 fails with invalid attributes" do
      player = insert(:player)
      port = insert(:port)
      scope = Scope.for(player: player)

      assert {:error, changeset} = Companies.create(scope, nil, "EIC", port.id)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "set_director/2 adds the given player as a director" do
      player = insert(:player)
      company = insert(:company)

      assert {:ok, _director} = Companies.set_director(company, player)

      # Verify player is now a director
      assert company.id in Companies.list_player_company_ids(player)
    end

    test "list_player_company_ids/1 returns ids of companies the player directs" do
      player = insert(:player)
      co1 = insert(:company)
      co2 = insert(:company)

      insert(:director, company: co1, player: player)
      insert(:director, company: co2, player: player)

      ids = Companies.list_player_company_ids(player)
      assert length(ids) == 2
      assert co1.id in ids
      assert co2.id in ids
    end

    test "record_transaction/8 updates treasury and creates ledger entry" do
      company = insert(:company, treasury: 1000)

      assert {:ok, %Company{treasury: 1500}} =
               Companies.record_transaction(
                 company.id,
                 500,
                 :market_trade,
                 :market,
                 Ecto.UUID.generate(),
                 ~U[2026-03-06 00:00:00Z]
               )

      # Verify ledger entry
      ledger_entry = Repo.one(Tradewinds.Companies.Ledger)
      assert ledger_entry.company_id == company.id
      assert ledger_entry.amount == 500
      assert ledger_entry.reason == :market_trade
      assert DateTime.compare(ledger_entry.occurred_at, ~U[2026-03-06 00:00:00Z]) == :eq
    end

    test "record_transaction/8 fails with invalid reason" do
      company = insert(:company)

      assert {:error, changeset} =
               Companies.record_transaction(
                 company.id,
                 100,
                 :invalid_reason,
                 :market,
                 Ecto.UUID.generate(),
                 ~U[2026-03-06 00:00:00Z]
               )

      assert "is invalid" in errors_on(changeset).reason
    end

    test "record_transaction/8 rolls back if insufficient funds" do
      company = insert(:company, treasury: 100)

      assert {:error, :insufficient_funds} =
               Companies.record_transaction(
                 company.id,
                 -200,
                 :market_trade,
                 :market,
                 Ecto.UUID.generate(),
                 ~U[2026-03-06 00:00:00Z]
               )

      # Verify treasury unchanged
      reloaded_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert reloaded_company.treasury == 100
    end
  end

  describe "upkeep" do
    test "process_monthly_upkeep/2 charges treasury and handles paid state" do
      company = insert(:company, treasury: 5000)
      ship_type = insert(:ship_type, upkeep: 1000)
      # 2 ships = 2000 upkeep
      insert(:ship, company: company, ship_type: ship_type)
      insert(:ship, company: company, ship_type: ship_type)

      # 1 warehouse at level 1, capacity 1000. New formula: (1000 * 0.08) + (1000 * 0.01 * 1^1.6) = 80 + 10 = 90
      insert(:warehouse, company: company, level: 1, capacity: 1000)

      now = ~U[2026-03-06 12:00:00Z]
      assert {:ok, 2090} = Companies.process_monthly_upkeep(company.id, now)

      updated_co = Repo.get!(Company, company.id)
      assert updated_co.treasury == 5000 - 2000 - 90
      assert updated_co.status == :active

      # Verify ledger entries
      ship_ledger =
        Repo.get_by(Tradewinds.Companies.Ledger, company_id: company.id, reason: :ship_upkeep)

      assert ship_ledger.amount == -2000

      warehouse_ledger =
        Repo.get_by(Tradewinds.Companies.Ledger,
          company_id: company.id,
          reason: :warehouse_upkeep
        )

      assert warehouse_ledger.amount == -90
    end

    test "process_monthly_upkeep/2 marks company bankrupt if insufficient funds" do
      company = insert(:company, treasury: 100)
      ship_type = insert(:ship_type, upkeep: 1000)
      insert(:ship, company: company, ship_type: ship_type, status: :docked)

      assert {:error, :bankrupt} = Companies.process_monthly_upkeep(company.id)

      assert Repo.get!(Company, company.id).status == :bankrupt
      # Treasury should be untouched
      assert Repo.get!(Company, company.id).treasury == 100
    end

    test "calculate_bailout/1 covers 3 months of upkeep" do
      company = insert(:company)
      ship_type = insert(:ship_type, upkeep: 1000)
      insert(:ship, company: company, ship_type: ship_type)

      # ship upkeep (1000) + warehouse upkeep (0) = 1000
      # 1000 * 3 = 3000
      assert Companies.calculate_bailout(company.id) == 3000
    end

    test "bailout/2 restores status and adds treasury" do
      company = insert(:company, treasury: 0, status: :bankrupt)

      assert {:ok, updated_co} = Companies.bailout(company.id, 10000)
      assert updated_co.status == :active
      assert updated_co.treasury == 10000

      # Verify ledger entry
      assert Repo.get_by(Tradewinds.Companies.Ledger, company_id: company.id, reason: :bailout)
    end
  end
end
