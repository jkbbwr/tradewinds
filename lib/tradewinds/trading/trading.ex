defmodule Tradewinds.Trading do
  alias Tradewinds.Repo
  alias Tradewinds.Companies
  alias Tradewinds.World
  alias Tradewinds.Ledger
  alias Tradewinds.Ships

  alias Tradewinds.Warehouses
  alias Tradewinds.Trading.Trader
  alias Tradewinds.Trading.TraderInventory
  alias Tradewinds.Trading.TraderPlan

  @quote_age 360

  def create_trader(port) do
    %Trader{}
    |> Trader.changeset(%{name: "#{port.name} Trader", port_id: port.id})
    |> Repo.insert()
  end

  def create_trader_plan(
        trader_id,
        item_id,
        average_acquisition_cost,
        ideal_stock_level,
        target_profit_margin,
        max_buy_sell_spread,
        price_elasticity,
        liquidity_factor,
        consumption_rate,
        reversion_rate,
        regional_cost
      ) do
    %TraderPlan{}
    |> TraderPlan.changeset(%{
      trader_id: trader_id,
      item_id: item_id,
      average_acquisition_cost: average_acquisition_cost,
      ideal_stock_level: ideal_stock_level,
      target_profit_margin: target_profit_margin,
      max_buy_sell_spread: max_buy_sell_spread,
      price_elasticity: price_elasticity,
      liquidity_factor: liquidity_factor,
      consumption_rate: consumption_rate,
      reversion_rate: reversion_rate,
      regional_cost: regional_cost
    })
    |> Repo.insert()
  end

  def buy_from_trader_quote(trader, item, amount) do
    with {:ok, trader_plan} <- fetch_trader_plan(trader, item),
         {:ok, inventory} <- fetch_trader_inventory(trader, item),
         :ok <- check_stock_quantity(inventory, amount) do
      price = spot_sell_price(trader_plan, inventory.stock)

      quote = sign_quote([item.id, amount, price])
      {:ok, quote}
    end
  end

  def sell_to_trader_quote(trader, item, amount, game_tick) do
    with {:ok, trader_plan} <- fetch_trader_plan(trader, item),
         {:ok, inventory} <- fetch_trader_inventory(trader, item) do
      price = spot_buy_price(trader_plan, inventory.stock)

      quote = sign_quote([item.id, amount, price, game_tick])
      {:ok, quote}
    end
  end

  def buy_from_trader(trader, company, quote, inventories, player, game_tick) do
    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, trader.port),
           {:ok, [item_id, quantity, price]} <- validate_quote(quote),
           {:ok, item} <- World.fetch_item(item_id),
           {:ok, inventory} <- fetch_trader_inventory(trader, item),
           :ok <- check_stock_quantity(inventory, quantity),
           :ok <- Companies.check_sufficient_funds(company, quantity * price),
           {:ok, _company} <- Companies.debit_treasury(company, quantity * price),
           {:ok, _inventory} <- debit_trader_stock(inventory, quantity),
           :ok <- fulfill_purchase(company, inventories, item, quantity) do
        Ledger.log_npc_trade(
          player,
          company,
          item,
          trader,
          quantity,
          price,
          :buy,
          game_tick
        )

        {:ok, :bought}
      else
        error -> error
      end
    end)
  end

  def sell_to_trader(player, company, trader, quote, inventories, game_tick) do
    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, trader.port),
           {:ok, [item_id, quantity, price, _quote_game_tick]} <- validate_quote(quote),
           {:ok, item} <- World.fetch_item(item_id),
           :ok <- check_enough_stock_in_port(inventories, quantity),
           {:ok, trader_plan} <- fetch_trader_plan(trader, item),
           {:ok, inventory} <- fetch_trader_inventory(trader, item),
           :ok <- credit_trader_stock(trader_plan, inventory, quantity, price),
           :ok <- fulfill_sale(company, inventories, item, quantity),
           {:ok, _company} <- Companies.credit_treasury(company, price * quantity) do
        Ledger.log_npc_trade(
          player,
          company,
          item,
          trader,
          quantity,
          price,
          :sell,
          game_tick
        )

        {:ok, :sold}
      else
        error -> error
      end
    end)
  end

  defp validate_quote(quote) do
    Phoenix.Token.verify(TradewindsWeb.Endpoint, "trader quote", quote, max_age: @quote_age)
  end

  defp sign_quote(data) do
    Phoenix.Token.sign(TradewindsWeb.Endpoint, "trader quote", data)
  end

  defp fulfill_purchase(company, inventories, item, quantity_to_fulfill) do
    Enum.reduce_while(inventories, quantity_to_fulfill, fn
      _, 0 ->
        {:cont, 0}

      %{type: :ship, id: ship_id, amount: amount}, remaining_quantity ->
        with {:ok, ship} <- Companies.fetch_ship(company, ship_id) do
          amount_to_load = min(amount, remaining_quantity)

          case Ships.load(ship, item, amount_to_load) do
            {:ok, _} -> {:cont, remaining_quantity - amount_to_load}
            error -> {:halt, error}
          end
        end

      %{type: :warehouse, id: warehouse_id, amount: amount}, remaining_quantity ->
        with {:ok, warehouse} <- Companies.fetch_warehouse(company, warehouse_id) do
          amount_to_store = min(amount, remaining_quantity)

          case Warehouses.store(warehouse, item, amount_to_store) do
            {:ok, _} -> {:cont, remaining_quantity - amount_to_store}
            error -> {:halt, error}
          end
        end
    end)
    |> case do
      0 -> :ok
      error -> error
    end
  end

  defp fulfill_sale(company, inventories, item, quantity_to_fulfill) do
    Enum.reduce_while(inventories, quantity_to_fulfill, fn
      _, 0 ->
        {:cont, 0}

      %{type: :ship, id: ship_id, amount: amount}, remaining_quantity ->
        with {:ok, ship} <- Companies.fetch_ship(company, ship_id) do
          amount_to_unload = min(amount, remaining_quantity)

          case Ships.unload(ship, item, amount_to_unload) do
            {:ok, _} -> {:cont, remaining_quantity - amount_to_unload}
            error -> {:halt, error}
          end
        end

      %{type: :warehouse, id: warehouse_id, amount: amount}, remaining_quantity ->
        with {:ok, warehouse} <- Companies.fetch_warehouse(company, warehouse_id) do
          amount_to_withdraw = min(amount, remaining_quantity)

          case Warehouses.withdraw(warehouse, item, amount_to_withdraw) do
            {:ok, _} -> {:cont, remaining_quantity - amount_to_withdraw}
            error -> {:halt, error}
          end
        end
    end)
    |> case do
      0 -> :ok
      error -> error
    end
  end

  defp check_stock_quantity(inventory, quantity) do
    if inventory.stock >= quantity do
      :ok
    else
      {:error, :not_enough_stock}
    end
  end

  defp check_enough_stock_in_port(stock, desired) do
    total = Enum.reduce(stock, 0, fn %{amount: amount}, acc -> amount + acc end)

    if total >= desired do
      :ok
    else
      {:error, :not_enough_stock_in_port}
    end
  end

  defp credit_trader_stock(trader_plan, inventory, quantity, price) do
    current_stock = inventory.stock
    current_avg_cost = trader_plan.average_acquisition_cost

    new_stock = current_stock + quantity

    new_avg_cost =
      ((current_avg_cost * current_stock + price) / (current_stock + quantity))
      |> round()

    trader_plan
    |> TraderPlan.changeset(%{average_acquisition_cost: new_avg_cost})
    |> Repo.update!()

    inventory
    |> TraderInventory.changeset(%{stock: new_stock})
    |> Repo.update!()

    :ok
  end

  defp debit_trader_stock(inventory, quantity) do
    inventory
    |> TraderInventory.changeset(%{stock: inventory.stock - quantity})
    |> Repo.update()
  end

  defp calculate_sell_price(trader_plan, current_stock) do
    trader_plan.average_acquisition_cost * trader_plan.target_profit_margin *
      :math.pow(trader_plan.ideal_stock_level / (current_stock + 1), trader_plan.price_elasticity)
  end

  defp spot_sell_price(trader_plan, current_stock) do
    sell_price = calculate_sell_price(trader_plan, current_stock)
    round(sell_price)
  end

  defp spot_buy_price(trader_plan, current_stock) do
    sell_price = calculate_sell_price(trader_plan, current_stock)

    stock_ratio = current_stock / trader_plan.ideal_stock_level
    capped_stock_ratio = min(stock_ratio, 1.0)
    spread_factor = trader_plan.max_buy_sell_spread * capped_stock_ratio

    buy_price = sell_price * (1 - spread_factor)
    round(buy_price)
  end

  defp fetch_trader_inventory(trader, item) do
    Repo.get_by(TraderInventory, trader_id: trader.id, item_id: item.id)
    |> Repo.ok_or(:trader_inventory_not_found)
  end

  defp fetch_trader_plan(trader, item) do
    Repo.get_by(TraderPlan, trader_id: trader.id, item_id: item.id)
    |> Repo.ok_or(:trader_plan_not_found)
  end
end
