defmodule Tradewinds.ScopeTest do
  use Tradewinds.DataCase

  alias Tradewinds.Scope

  describe "for/1" do
    test "creates scope with provided player and company_id" do
      player = build(:player)
      company_id = Ecto.UUID.generate()
      scope = Scope.for(player: player, company_id: company_id)

      assert scope.player == player
      assert scope.company_id == company_id
    end

    test "creates scope with only player" do
      player = build(:player)
      scope = Scope.for(player: player)

      assert scope.player == player
      assert scope.company_id == nil
    end
  end

  describe "for_player/1" do
    test "creates scope with provided player" do
      player = build(:player)
      scope = Scope.for_player(player)

      assert scope.player == player
      assert scope.company_id == nil
    end
  end

  describe "put_company_id/2" do
    test "sets company_id on scope" do
      new_id = Ecto.UUID.generate()
      scope = %Scope{company_id: nil}

      updated_scope = Scope.put_company_id(scope, new_id)

      assert updated_scope.company_id == new_id
    end
  end
end
