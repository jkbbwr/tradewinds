defmodule Tradewinds.MarketTest do
  use Tradewinds.DataCase
  alias Tradewinds.Market
  alias Tradewinds.Logistics
  alias Tradewinds.Companies
  alias Tradewinds.Companies.Company
  alias Tradewinds.Scope
  import Tradewinds.Factory

  setup do
    player = insert(:player)
    home_port = insert(:port)
    company = insert(:company, home_port: home_port, reputation: 1000, treasury: 10000)
    insert(:director, company: company, player: player)

    # Create a warehouse for the company
    {:ok, warehouse} =
      Logistics.add_cargo(
        insert(:warehouse, company: company, port: home_port).id,
        insert(:good).id,
        1
      )

    # Remove the dummy cargo used to trigger creation
    Logistics.remove_cargo(warehouse.warehouse_id, warehouse.good_id, 1)

    scope = Scope.for(player: player, company_id: company.id)
    good = insert(:good)
    port = home_port

    {:ok, scope: scope, company: company, good: good, port: port}
  end

  describe "posting orders" do
    test "posts a sell order successfully", %{
      scope: scope,
      company: company,
      good: good,
      port: port
    } do
      assert {:ok, order} = Market.post_order(scope, port.id, good.id, :sell, 100, 10)
      assert order.status == :open
      assert order.remaining == 10
      assert order.posted_reputation == company.reputation

      # Check fee deduction (Base fee 100 * (1000/1000) = 100)
      updated_company = Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury == 9900
    end

    test "fails if reputation is too low", %{
      scope: scope,
      company: company,
      good: good,
      port: port
    } do
      # Now at 100
      Companies.update_reputation(company.id, -900)

      assert {:error, :reputation_too_low} =
               Market.post_order(scope, port.id, good.id, :sell, 100, 10)
    end
  end

  describe "canceling orders" do
    test "cancels an open order successfully", %{scope: scope, good: good, port: port} do
      {:ok, order} = Market.post_order(scope, port.id, good.id, :sell, 100, 10)

      assert {:ok, cancelled_order} = Market.cancel_order(scope, order.id)
      assert cancelled_order.status == :cancelled
    end

    test "fails if order does not belong to company", %{scope: scope, good: good, port: port} do
      {:ok, order} = Market.post_order(scope, port.id, good.id, :sell, 100, 10)

      other_player = insert(:player)
      other_company = insert(:company, home_port: port)
      insert(:director, company: other_company, player: other_player)
      other_scope = Scope.for(player: other_player, company_id: other_company.id)

      assert {:error, :unauthorized_order} = Market.cancel_order(other_scope, order.id)

      # Order should still be open
      assert Repo.get(Tradewinds.Market.Order, order.id).status == :open
    end
  end

  describe "filling orders" do
    test "successfully fills a sell order (taker buys)", %{
      scope: scope,
      company: seller_company,
      good: good,
      port: port
    } do
      # Setup Seller
      warehouse = Logistics.fetch_warehouse(seller_company.id, port.id) |> elem(1)
      Logistics.add_cargo(warehouse.id, good.id, 10)

      # Setup Taker (Buyer)
      taker_player = insert(:player)
      taker_company = insert(:company, home_port: port, treasury: 5000, reputation: 1000)
      insert(:director, company: taker_company, player: taker_player)
      insert(:warehouse, company: taker_company, port: port)
      taker_scope = Scope.for(player: taker_player, company_id: taker_company.id)

      # Post order
      {:ok, order} = Market.post_order(scope, port.id, good.id, :sell, 100, 10)

      # Fill order
      assert {:ok, updated_order} = Market.fill_order(taker_scope, order.id, 5)
      assert updated_order.remaining == 5
      assert updated_order.status == :open

      # Check balances
      # 9900 (after post) + 500
      assert Repo.get(Company, seller_company.id).treasury == 10400
      # 5000 - 500
      assert Repo.get(Company, taker_company.id).treasury == 4500

      # Check inventory
      seller_inv =
        Repo.get_by(Logistics.WarehouseInventory, warehouse_id: warehouse.id, good_id: good.id)

      assert seller_inv.quantity == 5

      taker_warehouse = Logistics.fetch_warehouse(taker_company.id, port.id) |> elem(1)

      taker_inv =
        Repo.get_by(Logistics.WarehouseInventory,
          warehouse_id: taker_warehouse.id,
          good_id: good.id
        )

      assert taker_inv.quantity == 5

      # Check reputation
      assert Repo.get(Company, seller_company.id).reputation == 1001
      assert Repo.get(Company, taker_company.id).reputation == 1001
    end

    test "penalty branch: seller lacks goods", %{
      scope: scope,
      company: seller_company,
      good: good,
      port: port
    } do
      # Setup Taker (Buyer)
      taker_player = insert(:player)
      taker_company = insert(:company, home_port: port, treasury: 5000)
      insert(:director, company: taker_company, player: taker_player)
      insert(:warehouse, company: taker_company, port: port)
      taker_scope = Scope.for(player: taker_player, company_id: taker_company.id)

      # Post order
      {:ok, order} = Market.post_order(scope, port.id, good.id, :sell, 100, 10)

      # Try to fill (Seller has 0 goods)
      assert {:ok, {:trade_voided, {:inventory_not_found, _}, offender_id}} =
               Market.fill_order(taker_scope, order.id, 5)

      assert offender_id == seller_company.id

      # Check penalties for seller
      updated_seller = Repo.get(Company, seller_company.id)
      # 9900 - fine (0.05 * 500 = 25) = 9875
      assert updated_seller.treasury == 9875
      # 1000 - 50
      assert updated_seller.reputation == 950

      # Order should be nuked
      assert Repo.get(Tradewinds.Market.Order, order.id) == nil
    end
  end

  describe "sorting and blended price" do
    test "list_orders/3 sorts by price and reputation", %{
      scope: scope,
      good: good,
      port: port
    } do
      # Company 1: Rep 1000
      Market.post_order(scope, port.id, good.id, :sell, 100, 10)

      # Company 2: Rep 1200, same price
      player2 = insert(:player)
      company2 = insert(:company, reputation: 1200)
      insert(:director, company: company2, player: player2)
      scope2 = Scope.for(player: player2, company_id: company2.id)
      Market.post_order(scope2, port.id, good.id, :sell, 100, 10)

      # Company 3: Rep 1000, higher price
      Market.post_order(scope, port.id, good.id, :sell, 110, 10)

      orders =
        Market.list_orders(%{
          port_ids: [port.id],
          good_ids: [good.id],
          side: :sell,
          paginate: false
        })

      # Should be sorted by price ASC, then Reputation DESC
      assert [o1, o2, o3] = orders
      assert o1.order.price == 100 and o1.company_reputation == 1200
      assert o2.order.price == 100 and o2.company_reputation == 1000
      assert o3.order.price == 110
    end

    test "calculate_blended_price/4 handles multi-level fills", %{
      scope: scope,
      good: good,
      port: port
    } do
      Market.post_order(scope, port.id, good.id, :sell, 100, 10)
      Market.post_order(scope, port.id, good.id, :sell, 200, 10)

      # Buy 15: (10 * 100 + 5 * 200) / 15 = (1000 + 1000) / 15 = 2000 / 15 = 133.33
      assert {:ok, price} = Market.calculate_blended_price(port.id, good.id, :sell, 15)
      assert_in_delta price, 133.33, 0.01
    end
  end
end
