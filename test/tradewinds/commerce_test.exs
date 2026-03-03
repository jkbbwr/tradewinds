defmodule Tradewinds.CommerceTest do
  use Tradewinds.DataCase
  import Mox
  import Tradewinds.Factory
  alias Tradewinds.Commerce

  setup :verify_on_exit!

  describe "generate_quote/5" do
    test "returns :not_found if trader position does not exist" do
      assert {:error, :not_found} =
               Commerce.generate_quote(Ecto.UUID.generate(), Ecto.UUID.generate(), Ecto.UUID.generate(), :buy, 10)
    end

    test "returns :insufficient_stock if buying more than available" do
      good = insert(:good)
      port = insert(:port)
      trader = insert(:trader)

      insert(:trader_position,
        trader: trader,
        port: port,
        good: good,
        stock: 5
      )

      assert {:error, :insufficient_stock} =
               Commerce.generate_quote(Ecto.UUID.generate(), port.id, good.id, :buy, 10)
    end

    test "generates a valid buy quote with a token" do
      good = insert(:good, base_price: 100)
      port = insert(:port)
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

      assert {:ok, token, quote_data} = Commerce.generate_quote(Ecto.UUID.generate(), port.id, good.id, :buy, 10)
      
      assert is_binary(token)
      assert quote_data.action == :buy
      assert quote_data.quantity == 10
      assert quote_data.unit_price > 0
      assert quote_data.total_price == quote_data.unit_price * 10
    end

    test "generates a valid sell quote with a token" do
      good = insert(:good, base_price: 100)
      port = insert(:port)
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

      assert {:ok, _token, quote_data} = Commerce.generate_quote(Ecto.UUID.generate(), port.id, good.id, :sell, 10)
      assert quote_data.action == :sell
    end
  end

  describe "verify_quote/1" do
    test "verifies a token correctly" do
      good = insert(:good, base_price: 100)
      port = insert(:port)
      trader = insert(:trader)

      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)

      {:ok, token, generated_data} = Commerce.generate_quote(Ecto.UUID.generate(), port.id, good.id, :buy, 10)

      assert {:ok, verified_data} = Commerce.verify_quote(token)
      assert verified_data.unit_price == generated_data.unit_price
    end

    test "fails to verify a tampered or invalid token" do
      assert {:error, :invalid} = Commerce.verify_quote("invalid token")
    end
  end

  describe "execute_quote/2" do
    test "successfully executes a buy quote depositing into a ship" do
      Tradewinds.ClockMock
      |> expect(:get_tick, fn -> 1000 end)

      company = insert(:company, treasury: 10_000)
      port = insert(:port)
      good = insert(:good, base_price: 10)
      trader = insert(:trader)
      
      position = insert(:trader_position, trader: trader, port: port, good: good, stock: 100, target_stock: 100, elasticity: 1.0, spread: 0.05)
      
      ship = insert(:ship, company: company, port: port, status: :docked)

      {:ok, token, quote_data} = Commerce.generate_quote(company.id, port.id, good.id, :buy, 10)
      
      assert {:ok, _quote} = Commerce.execute_quote(token, [%{type: :ship, id: ship.id, quantity: 10}])

      # Verify company treasury decreased
      updated_company = Tradewinds.Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury == 10_000 - quote_data.total_price

      # Verify ship got cargo
      assert {:ok, 10} = Tradewinds.Fleet.current_cargo_total(ship.id)

      # Verify market stock decreased
      updated_position = Tradewinds.Repo.get(Tradewinds.Commerce.TraderPosition, position.id)
      assert updated_position.stock == 90
      assert updated_position.monthly_profit > 0
    end

    test "fails if destinations total quantity doesn't match quote" do
      company = insert(:company)
      port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)
      
      {:ok, token, _} = Commerce.generate_quote(company.id, port.id, good.id, :buy, 10)
      
      assert {:error, :quantity_mismatch} = Commerce.execute_quote(token, [%{type: :ship, id: Ecto.UUID.generate(), quantity: 5}])
    end

    test "fails if ship is at wrong port" do
      company = insert(:company, treasury: 10_000)
      port = insert(:port)
      wrong_port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, trader: trader, port: port, good: good, stock: 100)
      ship = insert(:ship, company: company, port: wrong_port, status: :docked)

      {:ok, token, _} = Commerce.generate_quote(company.id, port.id, good.id, :buy, 10)
      
      assert {:error, :wrong_location} = Commerce.execute_quote(token, [%{type: :ship, id: ship.id, quantity: 10}])
    end

    test "successfully executes a sell quote withdrawing from a ship" do
      Tradewinds.ClockMock
      |> expect(:get_tick, fn -> 1000 end)

      company = insert(:company, treasury: 10_000)
      port = insert(:port)
      good = insert(:good, base_price: 10)
      trader = insert(:trader)
      
      position = insert(:trader_position, trader: trader, port: port, good: good, stock: 100, target_stock: 100, elasticity: 1.0, spread: 0.05)
      
      ship = insert(:ship, company: company, port: port, status: :docked)
      insert(:ship_cargo, ship: ship, good: good, quantity: 10)

      {:ok, token, quote_data} = Commerce.generate_quote(company.id, port.id, good.id, :sell, 10)
      
      assert {:ok, _quote} = Commerce.execute_quote(token, [%{type: :ship, id: ship.id, quantity: 10}])

      # Verify company treasury increased
      updated_company = Tradewinds.Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury == 10_000 + quote_data.total_price

      # Verify ship lost cargo
      assert {:ok, 0} = Tradewinds.Fleet.current_cargo_total(ship.id)

      # Verify market stock increased
      updated_position = Tradewinds.Repo.get(Tradewinds.Commerce.TraderPosition, position.id)
      assert updated_position.stock == 110
    end
  end

  describe "execute_immediate/5" do
    test "successfully executes an immediate buy quote depositing into a ship" do
      Tradewinds.ClockMock
      |> expect(:get_tick, fn -> 1000 end)

      company = insert(:company, treasury: 10_000)
      port = insert(:port)
      good = insert(:good, base_price: 10)
      trader = insert(:trader)
      
      position = insert(:trader_position, trader: trader, port: port, good: good, stock: 100, target_stock: 100, elasticity: 1.0, spread: 0.05)
      
      ship = insert(:ship, company: company, port: port, status: :docked)

      assert {:ok, _quote} = Commerce.execute_immediate(company.id, port.id, good.id, :buy, [%{type: :ship, id: ship.id, quantity: 10}])

      # Verify company treasury decreased
      updated_company = Tradewinds.Repo.get(Tradewinds.Companies.Company, company.id)
      assert updated_company.treasury < 10_000

      # Verify ship got cargo
      assert {:ok, 10} = Tradewinds.Fleet.current_cargo_total(ship.id)

      # Verify market stock decreased
      updated_position = Tradewinds.Repo.get(Tradewinds.Commerce.TraderPosition, position.id)
      assert updated_position.stock == 90
      assert updated_position.monthly_profit > 0
    end

    test "fails if destinations quantity is 0 or less" do
      company = insert(:company)
      assert {:error, :invalid_quantity} = Commerce.execute_immediate(company.id, Ecto.UUID.generate(), Ecto.UUID.generate(), :buy, [%{type: :ship, id: Ecto.UUID.generate(), quantity: 0}])
    end
  end

  describe "simulate_daily_tick/4" do
    test "increases stock when below target" do
      # target 100, current 50. drift = 50 * 0.12 = 6. consumption = 50 * 0.04 = 2. new_stock = 50 + 6 - 2 = 54
      assert Commerce.simulate_daily_tick(50, 100, 0.12, 0.04) == 54
    end

    test "decreases stock when above target" do
      # target 100, current 150. drift = -50 * 0.12 = -6. consumption = 150 * 0.04 = 6. new_stock = 150 - 6 - 6 = 138
      assert Commerce.simulate_daily_tick(150, 100, 0.12, 0.04) == 138
    end

    test "clamps to 0" do
      # massive consumption
      assert Commerce.simulate_daily_tick(10, 100, 0.0, 1.5) == 0
    end

    test "clamps to 5x target" do
      # target 100, current 490, huge drift
      assert Commerce.simulate_daily_tick(490, 100, 0.0, -0.5) == 500
    end
  end

  describe "base_market_price/4" do
    test "calculates price based on scarcity" do
      # target 100, current 49 (ratio ~2). base_price 10, elasticity 1.
      assert_in_delta Commerce.base_market_price(49, 100, 10, 1.0), 20.0, 0.1
    end
  end

  describe "apply_volatility_jitter/1" do
    test "applies a jitter within +/- 3%" do
      price = 100
      jittered = Commerce.apply_volatility_jitter(price)
      assert jittered >= 97 and jittered <= 103
    end
  end

  describe "quotes/2" do
    test "applies spread correctly" do
      assert Commerce.quotes(100, 0.05) == {105, 95}
    end
  end

  describe "apply_slippage/4" do
    test "buying from NPC (ask) increases price based on order size" do
      # order 10, current 99. factor = 1 + (10 / 200) = 1.05
      assert Commerce.apply_slippage(:ask, 100, 10, 99) == 105
    end

    test "selling to NPC (bid) decreases price based on order size" do
      # order 10, current 99. factor = 1.05. quote = 110 / 1.05 = 104
      assert Commerce.apply_slippage(:bid, 110, 10, 99) == 104
    end
  end

  describe "clamp_price/2" do
    test "keeps price between floor and ceiling" do
      assert Commerce.clamp_price(5, 100) == 10  # floor is 10
      assert Commerce.clamp_price(1500, 100) == 1000 # ceiling is 1000
      assert Commerce.clamp_price(500, 100) == 500 # within bounds
    end
  end
end
