defmodule Tradewinds.Trading do
  alias Tradewinds.Repo
  alias Tradewinds.Companies
  alias Tradewinds.CompanyRepo
  alias Tradewinds.TradingRepo
  alias Tradewinds.Schema.TraderInventory
  alias Tradewinds.Schema.TraderPlan
  alias Tradewinds.Schema.Trade
  alias Tradewinds.Schema.ShipInventory
  alias Tradewinds.Schema.WarehouseInventory

  defdelegate fetch_trader_inventory(trader_id, item_id), to: TradingRepo
  defdelegate fetch_trader_plan(trader_id, item_id), to: TradingRepo

  defp validate_quote(quote) do
    Phoenix.Token.verify(TradewindsWeb.Endpoint, "trader quote", quote, max_age: 15)
  end

  def sell_to_player(player, company, trader, quote) do
    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, trader.port.id),
           {:ok, [item_id, quantity, price, game_tick]} <- validate_quote(quote),
           {:ok, inventory} <- TradingRepo.fetch_trader_inventory(trader.id, item_id),
           :ok <- check_stock_quantity(inventory, quantity),
           :ok <- Companies.check_sufficient_funds(company, quantity * price),
           {:ok, _company} <- CompanyRepo.debit_treasury(company, quantity * price),
           {:ok, _inventory} <- execute_sell(inventory, quantity) do
        create_trade_log(
          player.id,
          company.id,
          item_id,
          trader.id,
          quantity,
          price,
          # from the perspective of the player, they are buying something.
          :buy,
          game_tick
        )

        {:ok, :sold}
      else
        error -> error
      end
    end)
  end

  defp check_enough_stock_in_port(stock, desired) do
    total = Enum.reduce(stock, 0, fn %{amount: amount}, acc -> amount + acc end)

    if total >= desired do
      :ok
    else
      {:error, :not_enough_stock_in_port}
    end
  end

  def buy_from_player(player, company, trader, quote) do
    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, trader.port.id),
           {:ok, [item_id, quantity, price, game_tick]} <- validate_quote(quote),
           {:ok, trader_plan} <- TradingRepo.fetch_trader_plan(trader.id, item_id),
           {:ok, inventory} <- TradingRepo.fetch_trader_inventory(trader.id, item_id),
           stock_in_port <- TradingRepo.get_stock_in_port(company.id, trader.port.id, item_id),
           :ok <- check_enough_stock_in_port(stock_in_port, quantity),
           :ok <- execute_buy(trader_plan, inventory, quantity, price),
           :ok <- consume_stock(stock_in_port, quantity),
           {:ok, _company} <- CompanyRepo.credit_treasury(company, price * quantity) do
        create_trade_log(
          player.id,
          company.id,
          item_id,
          trader.id,
          quantity,
          price,
          # from the perspective of the player, they are selling something.
          :sell,
          game_tick
        )

        {:ok, :bought}
      else
        error -> error
      end
    end)
  end

  defp check_stock_quantity(inventory, quantity) do
    if inventory.stock >= quantity do
      :ok
    else
      {:error, :not_enough_stock}
    end
  end

  def execute_buy(trader_plan, inventory, quantity, price) do
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

  def execute_sell(inventory, quantity) do
    inventory
    |> TraderInventory.changeset(%{stock: inventory.stock - quantity})
    |> Repo.update()
  end

  defp create_trade_log(
         player_id,
         company_id,
         item_id,
         trader_id,
         amount,
         price,
         action,
         game_tick
       ) do
    %Trade{}
    |> Trade.changeset(%{
      player_id: player_id,
      company_id: company_id,
      item_id: item_id,
      trader_id: trader_id,
      amount: amount,
      price: price,
      action: action,
      game_tick: game_tick
    })
    |> Repo.insert()
  end

  defp calculate_sell_price(trader_plan, current_stock) do
    trader_plan.average_acquisition_cost * trader_plan.target_profit_margin *
      :math.pow(trader_plan.ideal_stock_level / (current_stock + 1), trader_plan.price_elasticity)
  end

  def spot_sell_price(trader_plan, current_stock) do
    sell_price = calculate_sell_price(trader_plan, current_stock)
    round(sell_price)
  end

  def spot_buy_price(trader_plan, current_stock) do
    sell_price = calculate_sell_price(trader_plan, current_stock)

    stock_ratio = current_stock / trader_plan.ideal_stock_level
    capped_stock_ratio = min(stock_ratio, 1.0)
    spread_factor = trader_plan.max_buy_sell_spread * capped_stock_ratio

    buy_price = sell_price * (1 - spread_factor)
    round(buy_price)
  end

  def consume_stock([], 0), do: :ok
  def consume_stock([], _quantity), do: {:error, :not_enough_stock_in_port}
  def consume_stock(_, 0), do: :ok

  def consume_stock([%{type: type, id: id, amount: amount} | tail], quantity) do
    schema =
      case type do
        "ship" -> ShipInventory
        "warehouse" -> WarehouseInventory
      end

    inventory = Repo.get!(schema, id)

    if quantity >= amount do
      Repo.delete!(inventory)
      remaining_quantity = quantity - amount
      consume_stock(tail, remaining_quantity)
    else
      inventory
      |> schema.changeset(%{amount: inventory.amount - quantity})
      |> Repo.update!()

      consume_stock([], 0)
    end
  end
end
