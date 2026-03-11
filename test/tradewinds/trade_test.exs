defmodule Tradewinds.TradeTest do
  use Tradewinds.DataCase
  import Mox
  import Tradewinds.Factory
  alias Tradewinds.Trade
  alias Tradewinds.Scope

  setup :verify_on_exit!

  setup do
    player = insert(:player)
    {:ok, player: player}
  end

  describe "quotes" do
    test "generate_quote/5 creates a valid signed token and quote data", %{player: player} do
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)

      assert {:ok, token, quote_data} =
               Trade.generate_quote(scope, port.id, good.id, :buy, 10)

      assert is_binary(token)
      assert quote_data.company_id == company.id
      assert quote_data.action == :buy
      assert quote_data.quantity == 10
      assert quote_data.unit_price > 0
    end

    test "verify_quote/1 verifies a valid token", %{player: player} do
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)

      {:ok, token, _} = Trade.generate_quote(scope, port.id, good.id, :buy, 10)
      assert {:ok, _quote_data} = Trade.verify_quote(token)
    end

    test "verify_quote/1 fails for invalid token" do
      assert {:error, :invalid} = Trade.verify_quote("invalid token")
    end
  end

  describe "execute_quote/2" do
    test "successfully executes buy trade with tax", %{player: player} do
      company = insert(:company, treasury: 10_000)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      # 5% tax
      port = insert(:port, tax_rate_bps: 500)
      good = insert(:good, base_price: 100)
      trader = insert(:trader)

      position =
        insert(:trader_position,
          trader: trader,
          port: port,
          good: good,
          stock: 100,
          target_stock: 100,
          elasticity: 1.0,
          spread: 0.05
        )

      ship = insert(:ship, company: company, port: port, status: :docked)

      {:ok, token, quote_data} =
        Trade.generate_quote(scope, port.id, good.id, :buy, 10)

      assert {:ok, _quote} =
               Trade.execute_quote(scope, token, [%{type: :ship, id: ship.id, quantity: 10}])

      # Verify company treasury decreased by total_price + tax
      tax_expected = floor(quote_data.total_price * 500 / 10000)
      updated_company = Tradewinds.Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury == 10_000 - quote_data.total_price - tax_expected

      # Verify tax ledger entry exists
      assert Repo.get_by(Tradewinds.Companies.Ledger, company_id: company.id, reason: :tax)

      # Verify ship got cargo
      assert {:ok, 10} = Tradewinds.Fleet.current_cargo_total(ship.id)

      # Verify market stock decreased
      updated_position = Tradewinds.Repo.get(Tradewinds.Trade.TraderPosition, position.id)
      assert updated_position.stock == 90
      assert updated_position.monthly_profit > 0
    end

    test "fails if destinations total quantity doesn't match quote", %{player: player} do
      company = insert(:company)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)

      {:ok, token, _} = Trade.generate_quote(scope, port.id, good.id, :buy, 10)

      assert {:error, :quantity_mismatch} =
               Trade.execute_quote(scope, token, [
                 %{type: :ship, id: Ecto.UUID.generate(), quantity: 5}
               ])
    end

    test "fails if ship is at wrong port", %{player: player} do
      company = insert(:company, treasury: 10_000)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)
      wrong_port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)

      ship = insert(:ship, company: company, port: wrong_port, status: :docked)

      {:ok, token, _} = Trade.generate_quote(scope, port.id, good.id, :buy, 10)

      assert {:error, :wrong_location} =
               Trade.execute_quote(scope, token, [%{type: :ship, id: ship.id, quantity: 10}])
    end

    test "successfully executes a sell quote withdrawing from a ship", %{player: player} do
      company = insert(:company, treasury: 10_000)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      # 2% tax
      port = insert(:port, tax_rate_bps: 200)
      good = insert(:good, base_price: 100)
      trader = insert(:trader)

      insert(:trader_position,
        trader: trader,
        port: port,
        good: good,
        stock: 100,
        target_stock: 100,
        elasticity: 1.0,
        spread: 0.05
      )

      ship = insert(:ship, company: company, port: port, status: :docked)
      Tradewinds.Fleet.add_cargo(ship.id, good.id, 10)

      {:ok, token, quote_data} =
        Trade.generate_quote(scope, port.id, good.id, :sell, 10)

      assert {:ok, _quote} =
               Trade.execute_quote(scope, token, [%{type: :ship, id: ship.id, quantity: 10}])

      # Verify company treasury increased by total_price - tax
      tax_expected = floor(quote_data.total_price * 200 / 10000)
      updated_company = Tradewinds.Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury == 10_000 + quote_data.total_price - tax_expected

      # Verify ship lost cargo
      assert {:ok, 0} = Tradewinds.Fleet.current_cargo_total(ship.id)
    end
  end

  describe "execute_immediate/5" do
    test "successfully executes buy trade without prior quote", %{player: player} do
      company = insert(:company, treasury: 10_000)
      insert(:director, company: company, player: player)
      scope = Scope.for(player: player, company_id: company.id)

      port = insert(:port)
      good = insert(:good, base_price: 100)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)

      ship = insert(:ship, company: company, port: port, status: :docked)

      assert {:ok, _} =
               Trade.execute_immediate(scope, port.id, good.id, :buy, [
                 %{type: :ship, id: ship.id, quantity: 10}
               ])

      updated_company = Tradewinds.Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury < 10_000
    end
  end

  describe "NPC Simulation" do
    test "simulate_daily_tick/5 calculates correctly" do
      # 100 stock, 100 target, 10% supply, 5% demand
      # drift = (100 - 100) * 0.1 = 0
      # consumption = 100 * 0.05 = 5
      # result = 95
      assert Trade.simulate_daily_tick(100, 100, 0.1, 0.05) == 95

      # 50 stock, 100 target, 10% supply, 5% demand
      # drift = (100 - 50) * 0.1 = 5
      # consumption = 50 * 0.05 = 2
      # result = 50 + 5 - 2 = 53
      assert Trade.simulate_daily_tick(50, 100, 0.1, 0.05) == 53
    end

    test "simulate_trader/1 updates all positions for a trader" do
      trader = insert(:trader)
      p1 = insert(:trader_position, trader: trader, stock: 100, target_stock: 100)
      p2 = insert(:trader_position, trader: trader, stock: 50, target_stock: 100)

      assert {:ok, _results} = Trade.simulate_trader(trader.id)

      assert Repo.get(Tradewinds.Trade.TraderPosition, p1.id).stock < 100
      assert Repo.get(Tradewinds.Trade.TraderPosition, p2.id).stock > 50
    end
  end
end
