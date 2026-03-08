defmodule Tradewinds.Commerce do
  @moduledoc """
  The Commerce context.
  Handles interactions between players and NPC traders, including price calculation,
  signed quotes, immediate execution, and daily market simulations.
  """

  alias Tradewinds.Repo
  import Ecto.Query

  @doc """
  Generates a signed, stateless quote for a company to buy or sell goods from/to
  a trader. Applies active economic shocks to base price and volatility. Returns
  `{:ok, token, quote_data}` or `{:error, reason}`.
  """
  def generate_quote(
        %Tradewinds.Scope{company_id: company_id},
        port_id,
        good_id,
        action,
        quantity
      )
      when action in [:buy, :sell] and is_integer(quantity) and quantity > 0 do
    with {:ok, company} <- Tradewinds.Companies.fetch_company(company_id),
         {:ok, :active} <- Tradewinds.Companies.is_active?(company),
         %Tradewinds.Commerce.TraderPosition{} = position <-
           Repo.one(
             from p in Tradewinds.Commerce.TraderPosition,
               where: p.port_id == ^port_id and p.good_id == ^good_id,
               preload: [:good]
           ) || {:error, :not_found},
         :ok <- ensure_available_stock(position, action, quantity),
         now <- DateTime.utc_now(),
         modifiers <-
           Tradewinds.Economy.get_active_modifiers(port_id, good_id, now),
         base_price <- round(position.good.base_price * modifiers.price),
         market_price <-
           base_market_price(
             position.stock,
             position.target_stock,
             base_price,
             position.elasticity
           ),
         final_base_price <-
           apply_volatility_jitter(market_price, modifiers.volatility),
         {ask, bid} <- quotes(final_base_price, position.spread),
         {quote_price, impact_action} <-
           quote_price_and_action(action, ask, bid),
         final_unit_price <-
           apply_slippage(
             impact_action,
             quote_price,
             quantity,
             position.stock
           )
           |> clamp_price(base_price),
         quote_data <-
           %{
             company_id: company_id,
             port_id: port_id,
             good_id: good_id,
             action: action,
             quantity: quantity,
             unit_price: final_unit_price,
             total_price: final_unit_price * quantity,
             market_price: final_base_price,
             spread: position.spread,
             timestamp: DateTime.to_iso8601(now)
           },
         token <-
           Phoenix.Token.sign(TradewindsWeb.Endpoint, "trader_quote", quote_data) do
      {:ok, token, quote_data}
    end
  end

  defp ensure_available_stock(
         %Tradewinds.Commerce.TraderPosition{stock: stock},
         :buy,
         quantity
       )
       when quantity > stock,
       do: {:error, :insufficient_stock}

  defp ensure_available_stock(_position, _action, _quantity), do: :ok

  defp quote_price_and_action(:buy, ask, _bid), do: {ask, :ask}
  defp quote_price_and_action(:sell, _ask, bid), do: {bid, :bid}

  @doc """
  Verifies a trader quote token.
  Enforces a maximum age (e.g., 120 seconds) to prevent stale price execution.
  """
  def verify_quote(token) do
    # 120 seconds max age
    Phoenix.Token.verify(TradewindsWeb.Endpoint, "trader_quote", token, max_age: 120)
  end

  @doc """
  Executes a previously signed quote atomically.
  Distributes or withdraws the goods across multiple specified `destinations` (ships/warehouses).
  """
  def execute_quote(%Tradewinds.Scope{company_id: company_id}, token, destinations) when is_list(destinations) do
    with {:ok, quote_data} <- verify_quote(token),
         :ok <- if(quote_data.company_id == company_id, do: :ok, else: {:error, :unauthorized}),
         {:ok, company} <- Tradewinds.Companies.fetch_company(company_id),
         {:ok, :active} <- Tradewinds.Companies.is_active?(company),
         :ok <- validate_destinations_total(quote_data, destinations) do
      # Decode the timestamp back to DateTime
      {:ok, quote_timestamp, _} = DateTime.from_iso8601(quote_data.timestamp)
      quote_data = Map.put(quote_data, :timestamp, quote_timestamp)

      Repo.transact(fn ->
        with {:ok, position} <- fetch_position_for_update(quote_data.port_id, quote_data.good_id),
             :ok <- validate_trade_execution(quote_data, position, destinations) do
          perform_execution(quote_data, position, destinations, quote_data.timestamp)
        else
          {:error, reason} -> Repo.rollback(reason)
        end
      end)
    end
  end

  @doc """
  Calculates and executes a trade immediately in one atomic step without requiring a signed quote.
  Applies all economic shocks dynamically before execution.
  """
  def execute_immediate(
        %Tradewinds.Scope{company_id: company_id},
        port_id,
        good_id,
        action,
        destinations
      )
      when action in [:buy, :sell] and is_list(destinations) do
    total_qty = Enum.reduce(destinations, 0, fn %{quantity: qty}, acc -> acc + qty end)

    if total_qty <= 0 do
      {:error, :invalid_quantity}
    else
      Repo.transact(fn ->
          with {:ok, company} <- Tradewinds.Companies.fetch_company(company_id),
               {:ok, :active} <- Tradewinds.Companies.is_active?(company),
               {:ok, position} <- fetch_position_for_update(port_id, good_id),
               :ok <-
                 validate_trade_execution(
                   %{action: action, quantity: total_qty},
                   position,
                   destinations
                 ) do
            now = DateTime.utc_now()
            modifiers = Tradewinds.Economy.get_active_modifiers(port_id, good_id, now)

            base_price = round(position.good.base_price * modifiers.price)

            market_price =
              base_market_price(
                position.stock,
                position.target_stock,
                base_price,
                position.elasticity
              )

            final_base_price = apply_volatility_jitter(market_price, modifiers.volatility)

            {ask, bid} = quotes(final_base_price, position.spread)

            quote_price = if action == :buy, do: ask, else: bid
            impact_action = if action == :buy, do: :ask, else: :bid

            final_unit_price =
              apply_slippage(impact_action, quote_price, total_qty, position.stock)
              |> clamp_price(base_price)

            quote_data = %{
              company_id: company_id,
              port_id: port_id,
              good_id: good_id,
              action: action,
              quantity: total_qty,
              unit_price: final_unit_price,
              total_price: final_unit_price * total_qty,
              market_price: final_base_price,
              spread: position.spread
            }

            perform_execution(quote_data, position, destinations, now)
          else
            {:error, reason} -> Repo.rollback(reason)
          end
        end)
    end
  end

  # Ensures the requested distribution of goods perfectly matches the quoted total quantity.
  defp validate_destinations_total(quote_data, destinations) do
    total_qty = Enum.reduce(destinations, 0, fn %{quantity: qty}, acc -> acc + qty end)

    if total_qty == quote_data.quantity do
      :ok
    else
      {:error, :quantity_mismatch}
    end
  end

  # Fetches and row-locks an NPC trader position to prevent race conditions during execution.
  defp fetch_position_for_update(port_id, good_id) do
    Tradewinds.Commerce.TraderPosition
    |> where(port_id: ^port_id, good_id: ^good_id)
    |> lock("FOR UPDATE")
    |> preload([:good])
    |> Repo.one()
    |> Repo.ok_or(:market_not_found)
  end

  # Verifies the NPC actually has enough stock to fulfill a buy order.
  defp validate_trade_execution(quote_data, position, _destinations) do
    if quote_data.action == :buy && position.stock < quote_data.quantity do
      {:error, :insufficient_market_stock}
    else
      :ok
    end
  end

  # The core atomic execution block. Charges the treasury, moves cargo, updates NPC stock, and writes a trade log.
  defp perform_execution(quote_data, position, destinations, now) do
    amount =
      if quote_data.action == :buy, do: -quote_data.total_price, else: quote_data.total_price

    {buyer_id, seller_id} =
      if quote_data.action == :buy,
        do: {quote_data.company_id, Tradewinds.Economy.system_npc_id()},
        else: {Tradewinds.Economy.system_npc_id(), quote_data.company_id}

    tax_amount =
      Tradewinds.Economy.calculate_tax_for_port(quote_data.total_price, quote_data.port_id)

    with {:ok, _} <-
           Tradewinds.Companies.record_transaction(
             quote_data.company_id,
             amount,
             :npc_trade,
             :market,
             quote_data.port_id,
             now
           ),
         {:ok, _} <-
           (if tax_amount > 0 do
              Tradewinds.Companies.record_transaction(
                quote_data.company_id,
                -tax_amount,
                :tax,
                :market,
                quote_data.port_id,
                now,
                meta: %{base_amount: quote_data.total_price, port_id: quote_data.port_id}
              )
            else
              {:ok, :no_tax}
            end),
         {:ok, _} <- update_cargo_destinations(quote_data, destinations),
         {:ok, _} <- update_market_position(quote_data, position),
         {:ok, _} <-
           Tradewinds.Economy.log_trade(%{
             occurred_at: now,
             quantity: quote_data.quantity,
             price: quote_data.unit_price,
             source: :npc_trader,
             port_id: quote_data.port_id,
             good_id: quote_data.good_id,
             buyer_id: buyer_id,
             seller_id: seller_id
           }) do
      {:ok, quote_data}
    end
  end

  # Iterates over specified destinations, adding or removing goods while validating location and ownership.
  defp update_cargo_destinations(quote_data, destinations) do
    result =
      Enum.reduce_while(destinations, :ok, fn %{type: type, id: id, quantity: qty}, :ok ->
        res =
          case {quote_data.action, type} do
            {:buy, :ship} ->
              with {:ok, ship} <- Tradewinds.Fleet.fetch_ship(id),
                   :ok <- validate_location(ship, quote_data.port_id),
                   :ok <- validate_ownership(ship, quote_data.company_id),
                   {:ok, _} <- Tradewinds.Fleet.add_cargo(id, quote_data.good_id, qty) do
                :ok
              end

            {:buy, :warehouse} ->
              with {:ok, warehouse} <- Tradewinds.Logistics.fetch_warehouse(id),
                   :ok <- validate_location(warehouse, quote_data.port_id),
                   :ok <- validate_ownership(warehouse, quote_data.company_id),
                   {:ok, _} <- Tradewinds.Logistics.add_cargo(id, quote_data.good_id, qty) do
                :ok
              end

            {:sell, :ship} ->
              with {:ok, ship} <- Tradewinds.Fleet.fetch_ship(id),
                   :ok <- validate_location(ship, quote_data.port_id),
                   :ok <- validate_ownership(ship, quote_data.company_id),
                   {:ok, _} <- Tradewinds.Fleet.remove_cargo(id, quote_data.good_id, qty) do
                :ok
              end

            {:sell, :warehouse} ->
              with {:ok, warehouse} <- Tradewinds.Logistics.fetch_warehouse(id),
                   :ok <- validate_location(warehouse, quote_data.port_id),
                   :ok <- validate_ownership(warehouse, quote_data.company_id),
                   {:ok, _} <- Tradewinds.Logistics.remove_cargo(id, quote_data.good_id, qty) do
                :ok
              end
          end

        case res do
          :ok -> {:cont, :ok}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case result do
      :ok -> {:ok, :done}
      err -> err
    end
  end

  # Validates that an entity (ship/warehouse) is physically present at the requested port.
  defp validate_location(%{port_id: port_id}, expected_port_id) when port_id == expected_port_id,
    do: :ok

  defp validate_location(_, _), do: {:error, :wrong_location}

  # Validates that the trading company owns the target entity (ship/warehouse).
  defp validate_ownership(%{company_id: company_id}, expected_company_id)
       when company_id == expected_company_id,
       do: :ok

  defp validate_ownership(_, _), do: {:error, :wrong_owner}

  # Adjusts the NPC's stock balance and accrues virtual profit based on the spread.
  defp update_market_position(quote_data, position) do
    new_stock =
      if quote_data.action == :buy,
        do: position.stock - quote_data.quantity,
        else: position.stock + quote_data.quantity

    profit_accrued = floor(quote_data.quantity * quote_data.market_price * quote_data.spread)

    position
    |> Tradewinds.Commerce.TraderPosition.changeset(%{
      stock: new_stock,
      monthly_profit: position.monthly_profit + profit_accrued
    })
    |> Repo.update()
  end

  @doc """
  Calculates the new stock after one day of simulation.
  Based on stock drift and consumption towards a target equilibrium.
  """
  def simulate_daily_tick(
        current_stock,
        target_stock,
        supply_rate,
        demand_rate,
        modifiers \\ %{supply: 1.0, demand: 1.0}
      ) do
    effective_supply_rate = supply_rate * modifiers.supply
    effective_demand_rate = demand_rate * modifiers.demand

    drift = floor((target_stock - current_stock) * effective_supply_rate)
    consumption = floor(current_stock * effective_demand_rate)
    max_stock = target_stock * 5

    new_stock = current_stock + drift - consumption
    clamp(new_stock, 0, max_stock)
  end

  @doc """
  Runs the daily simulation for all positions of a specific trader.
  Applies economic modifiers, computes stock drift/consumption, aggregates player flow, and updates the database.
  """
  def simulate_trader(trader_id, now \\ DateTime.utc_now()) do
    positions =
      Tradewinds.Commerce.TraderPosition
      |> where([p], p.trader_id == ^trader_id)
      |> Repo.all()

    # Look back 1 game day (576 seconds) for trade volume
    start_time = DateTime.add(now, -576, :second)

    Repo.transact(fn ->
      Enum.each(positions, fn position ->
        modifiers =
          Tradewinds.Economy.get_active_modifiers(position.port_id, position.good_id, now)

        # 1. Aggregate net player flow for this specific position over the last day
        flow =
          Tradewinds.Economy.net_player_flow_from_npc(
            position.port_id,
            position.good_id,
            start_time,
            now
          )

        # 2. Adjust target stock based on flow
        # If flow > 0 (players buying), demand is high, so increase target stock.
        # If flow < 0 (players selling), demand is low, so decrease target stock.
        target_adjustment = floor(flow * 0.1)
        max_adjustment = ceil(position.target_stock * 0.1)
        clamped_adjustment = clamp(target_adjustment, -max_adjustment, max_adjustment)
        new_target_stock = max(10, position.target_stock + clamped_adjustment)

        # 3. Adjust spread based on flow intensity
        # High flow magnitude means high volatility/demand; increase spread to capitalize.
        # Low/zero flow decays the spread back down to encourage trading.
        new_spread =
          if abs(flow) > 100 do
            min(0.20, position.spread + 0.005)
          else
            max(0.05, position.spread - 0.001)
          end

        new_stock =
          simulate_daily_tick(
            position.stock,
            new_target_stock,
            position.supply_rate,
            position.demand_rate,
            modifiers
          )

        position
        |> Tradewinds.Commerce.TraderPosition.update_simulation_changeset(%{
          stock: new_stock,
          target_stock: new_target_stock,
          spread: new_spread
        })
        |> Repo.update!()
      end)

      {:ok, :simulated}
    end)
  end

  @doc """
  Resets the monthly profit for a trader's positions.
  This allows the trader to reassess their stance (e.g., adjust spread) in the future.
  """
  def reset_trader_stances(trader_id) do
    Tradewinds.Commerce.TraderPosition
    |> where(trader_id: ^trader_id)
    |> Repo.update_all(set: [monthly_profit: 0, updated_at: DateTime.utc_now()])

    {:ok, :reset}
  end

  @doc """
  Calculates the base market price based on elasticity and how far stock deviates from the target.
  """
  def base_market_price(current_stock, target_stock, base_price, elasticity) do
    price_ratio = target_stock / (current_stock + 1)
    base_price * :math.pow(price_ratio, elasticity)
  end

  @doc """
  Injects random noise to the market price.
  Baseline noise is +/- 3%. Volatility modifier from shocks is applied.
  """
  def apply_volatility_jitter(market_price, vol_modifier \\ 1.0) do
    # random noise between -3% and +3%
    base_noise = :rand.uniform() * 0.06 - 0.03
    noise = 1.0 + base_noise * vol_modifier
    round(market_price * noise)
  end

  @doc """
  Returns {ask_price, bid_price} based on the final base price and spread.
  Ask is what the player pays to buy. Bid is what the player receives when selling.
  """
  def quotes(final_base_price, spread) do
    ask = floor(final_base_price * (1.0 + spread))
    bid = floor(final_base_price * (1.0 - spread))
    {ask, bid}
  end

  @doc """
  Applies slippage (average impact factor) to a quote price based on the order quantity.
  Uses the average fill price (half the maximum slippage) to reward bulk trading.
  """
  def apply_slippage(:ask, quote_price, order_qty, current_stock) do
    # Buying from NPC: price goes up
    # average_impact_factor = 1.0 + (order_qty / (2 * (current_stock + 1)))
    quote_price + div(quote_price * order_qty, 2 * (current_stock + 1))
  end

  def apply_slippage(:bid, quote_price, order_qty, current_stock) do
    # Selling to NPC: price goes down
    # average_impact_factor = 1.0 + (order_qty / (2 * (current_stock + 1)))
    # final_price = quote_price / average_impact_factor
    div(quote_price * 2 * (current_stock + 1), 2 * (current_stock + 1) + order_qty)
  end

  @doc """
  Clamps the final unit price to not fall below 10% of base price or exceed 1000% of base price.
  """
  def clamp_price(price, base_price) do
    floor_price = floor(base_price * 0.1)
    ceil_price = floor(base_price * 10.0)
    clamp(price, floor_price, ceil_price)
  end

  # Helper for clamping integer boundaries.
  defp clamp(value, min, max) do
    value |> max(min) |> min(max)
  end
end
