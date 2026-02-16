defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase

  alias Tradewinds.Companies
  alias Tradewinds.Scope

  describe "companies" do
    test "create/2 creates a company and assigns the player as director" do
      player = insert(:player)
      scope = Scope.for(player: player)
      attrs = %{name: "East India Company", ticker: "EIC", treasury: 10000}

      assert {:ok, company} = Companies.create(scope, attrs)
      assert company.name == "East India Company"
      assert company.ticker == "EIC"
      assert company.treasury == 10000

      # Verify directorship
      company_ids = Companies.list_player_company_ids(player)
      assert company.id in company_ids
    end

    test "create/2 fails with invalid attributes" do
      player = insert(:player)
      scope = Scope.for(player: player)
      attrs = %{name: nil}

      assert {:error, changeset} = Companies.create(scope, attrs)
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
  end
end
