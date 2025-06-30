defmodule Tradewinds.Trading do
  alias Tradewinds.Repo
  alias Tradewinds.Companies
  alias Tradewinds.Schema.Item
  alias Tradewinds.Schema.TraderInventory
  alias Tradewinds.Schema.TraderPlan
  alias Tradewinds.Schema.Trade
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Warehouse
  alias Tradewinds.Schema.ShipInventory
  alias Tradewinds.Schema.WarehouseInventory
  import Ecto.Query

  @moduledoc """
  The Trading context.
  Encapsulates the primary game loop of trade, managing ships, cargo, and markets.
  """

  @doc """

  First check the player is in the port they want to buy from
  """
  defp validate_quote(quote) do
    Phoenix.Token.verify(TradewindsWeb.Endpoint, "trader quote", quote, max_age: 15)
  end

  def get_trader_inventory(trader_id, item_id) do
    Repo.fetch_by(TraderInventory, trader_id: trader_id, item_id: item_id)
  end

  def get_trader_plan(trader_id, item_id) do
    Repo.fetch_by(TraderPlan, trader_id: trader_id, item_id: item_id)
  end

  def sell_to_player(player, company, trader, quote) do
    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, trader.port.id),
           {:ok, [item_id, quantity, price, game_tick]} <- validate_quote(quote),
           {:ok, inventory} <- get_trader_inventory(trader.id, item_id),
           :ok <- check_stock_quantity(inventory, quantity),
           :ok <- Companies.check_sufficient_funds(company, quantity * price) do
        Companies.debit_treasury(company, quantity * price)
        execute_sell(inventory, quantity)

        create_trade_log(
          player.id,
          company.id,
          item_id,
          trader.port.id,
          quantity,
          price,
          :buy,
          game_tick
        )

        {:ok, :sold}
      end
    end)
  end

  def buy_from_player(player, company, trader, quote) do
    Repo.transact(fn ->
      with :ok <- Companies.check_presence_in_port(company, trader.port_id),
           {:ok, [item_id, quantity, price, game_tick]} <- validate_quote(quote),
           stock_in_port <- get_stock_in_port(company.id, trader.port_id, item_id) do
        # TODO: do something with ship and warehouse
        {:ok, :bought}
      end
    end)
  end

  def get_stock_in_port(company_id, port_id, item_id) do
    ship_inventory =
      from s in Ship,
           join: si in ShipInventory,
           on: s.id == si.ship_id,
           where: s.company_id == ^company_id and s.port_id == ^port_id and si.item_id == ^item_id,
           select: %{type: "ship", id: si.id, amount: si.amount}

    warehouse_inventory =
      from w in Warehouse,
           join: wi in WarehouseInventory,
           on: w.id == wi.warehouse_id,
           where:
             w.company_id == ^company_id and w.port_id == ^port_id and wi.item_id == ^item_id,
           select: %{type: "warehouse", id: wi.id, amount: wi.amount}

    query =
      from u in subquery(ship_inventory),
      union_all: ^subquery(warehouse_inventory)

    Repo.all(query)
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
  end

  def execute_sell(inventory, quantity) do
    inventory
    |> TraderInventory.changeset(%{stock: inventory.stock - quantity})
    |> Repo.update!()
  end

  defp create_trade_log(
         player_id,
         company_id,
         item_id,
         port_id,
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
      port_id: port_id,
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
end
