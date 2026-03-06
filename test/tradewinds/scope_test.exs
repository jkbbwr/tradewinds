defmodule Tradewinds.ScopeTest do
  use Tradewinds.DataCase

  alias Tradewinds.Scope

  describe "for/1" do
    test "creates scope with provided player and explicit company_ids" do
      player = build(:player)
      company_id = Ecto.UUID.generate()
      scope = Scope.for(player: player, company_ids: [company_id])

      assert scope.player == player
      assert scope.company_ids == [company_id]
    end

    test "creates scope and lazy-loads company_ids from database if not provided" do
      player = insert(:player)
      company = insert(:company)
      insert(:director, player: player, company: company)

      scope = Scope.for(player: player)

      assert scope.player == player
      assert scope.company_ids == [company.id]
    end

    test "creates scope with empty list if player is nil" do
      scope = Scope.for(player: nil)

      assert scope.player == nil
      assert scope.company_ids == []
    end
  end

  describe "authorizes?/2" do
    test "returns :ok if company_id is in scope's company_ids and company is active" do
      company = insert(:company, status: :active)
      scope = %Scope{company_ids: [company.id]}

      assert Scope.authorizes?(scope, company.id) == :ok
    end

    test "returns {:error, :bankrupt} if company is bankrupt" do
      company = insert(:company, status: :bankrupt)
      scope = %Scope{company_ids: [company.id]}

      assert Scope.authorizes?(scope, company.id) == {:error, :bankrupt}
    end

    test "returns {:error, :unauthorized} if company_id is not in scope" do
      company = insert(:company)
      other_id = Ecto.UUID.generate()
      scope = %Scope{company_ids: [company.id]}

      assert Scope.authorizes?(scope, other_id) == {:error, :unauthorized}
    end

    test "returns {:error, :unauthorized} if scope is not a Scope struct" do
      company = insert(:company)

      assert Scope.authorizes?(%{company_ids: [company.id]}, company.id) ==
               {:error, :unauthorized}
    end
  end

  describe "put_company_id/2" do
    test "adds company_id to scope" do
      initial_id = Ecto.UUID.generate()
      new_id = Ecto.UUID.generate()
      scope = %Scope{company_ids: [initial_id]}

      updated_scope = Scope.put_company_id(scope, new_id)

      assert new_id in updated_scope.company_ids
      assert initial_id in updated_scope.company_ids
    end
  end
end
