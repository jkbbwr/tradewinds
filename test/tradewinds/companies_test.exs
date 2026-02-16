defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase

  alias Tradewinds.Companies
  alias Tradewinds.Companies.Company
  alias Tradewinds.Scope

  describe "companies" do
    test "create/5 creates a company and assigns the player as director" do
      player = insert(:player)
      port = insert(:port)
      scope = Scope.for(player: player)

      assert {:ok, company} = Companies.create(scope, "East India Company", "EIC", port.id, 10000)
      assert company.name == "East India Company"
      assert company.ticker == "EIC"
      assert company.treasury == 10000
      assert company.home_port_id == port.id

      # Verify directorship
      company_ids = Companies.list_player_company_ids(player)
      assert company.id in company_ids
    end

    test "create/5 fails with invalid attributes" do
      player = insert(:player)
      port = insert(:port)
      scope = Scope.for(player: player)

      assert {:error, changeset} = Companies.create(scope, nil, "EIC", port.id)
      assert "can't be blank" in errors_on(changeset).name
    end

    test "add_director/2 adds the current player in scope as a director" do
      player = insert(:player)
      company = insert(:company)

      # We need a scope that is authorized for this company.
      # Since add_director/2 checks Scope.authorizes?, we simulate an existing director
      scope = %Scope{player: player, company_ids: [company.id]}

      assert {:ok, _director} = Companies.add_director(scope, company)

      # Verify player is now a director
      assert company.id in Companies.list_player_company_ids(player)
    end

    test "add_director/2 fails if the scope is not authorized for the company" do
      player = insert(:player)
      company = insert(:company)
      # Empty company_ids
      scope = Scope.for(player: player)

      assert {:error, :unauthorized} = Companies.add_director(scope, company)
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
      player = insert(:player)
      company = insert(:company, treasury: 1000)
      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:ok, %Company{treasury: 1500}} =
               Companies.record_transaction(
                 scope,
                 company.id,
                 500,
                 :market_trade,
                 "market",
                 Ecto.UUID.generate(),
                 100
               )

      # Verify ledger entry
      ledger_entry = Repo.one(Tradewinds.Companies.Ledger)
      assert ledger_entry.company_id == company.id
      assert ledger_entry.amount == 500
      assert ledger_entry.reason == :market_trade
      assert ledger_entry.tick == 100
    end

    test "record_transaction/8 fails with invalid reason" do
      player = insert(:player)
      company = insert(:company)
      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:error, changeset} =
               Companies.record_transaction(
                 scope,
                 company.id,
                 100,
                 :invalid_reason,
                 "market",
                 Ecto.UUID.generate(),
                 100
               )

      assert "is invalid" in errors_on(changeset).reason
    end

    test "record_transaction/8 rolls back if insufficient funds" do
      player = insert(:player)
      company = insert(:company, treasury: 100)
      scope = Scope.for(player: player, company_ids: [company.id])

      assert {:error, :insufficient_funds} =
               Companies.record_transaction(
                 scope,
                 company.id,
                 -200,
                 :market_trade,
                 "market",
                 Ecto.UUID.generate(),
                 100
               )

      # Verify treasury unchanged
      reloaded_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert reloaded_company.treasury == 100
    end
  end
end
