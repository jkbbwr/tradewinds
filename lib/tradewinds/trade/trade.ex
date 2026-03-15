defmodule Tradewinds.Trade do
  @moduledoc """
  The Trade context.
  Handles interactions between players and NPC traders, including price calculation,
  signed quotes, immediate execution, and daily market simulations.
  """

  alias Tradewinds.Repo
  import Ecto.Query

  @doc """
  Lists all NPC traders.
  """
  def list_traders(params \\ %{}) do
    opts =
      params
      |> Map.take([:after, :before, :limit])
      |> Map.to_list()
      |> Keyword.merge(cursor_fields: [inserted_at: :desc, id: :desc], limit: 50)

    Tradewinds.Trade.Trader
    |> order_by(desc: :inserted_at, desc: :id)
    |> Repo.paginate(opts)
  end

  def list_trader_positions(trader_id, params \\ %{}) do
    opts =
      params
      |> Map.take([:after, :before, :limit])
      |> Map.to_list()
      |> Keyword.merge(cursor_fields: [inserted_at: :desc, id: :desc], limit: 50)

    query = Tradewinds.Trade.TraderPosition

    query = if trader_id, do: where(query, trader_id: ^trader_id), else: query

    query
    |> order_by(desc: :inserted_at, desc: :id)
    |> preload([:good])
    |> Repo.paginate(opts)
  end

  defp fetch_position(port_id, good_id) do
    Repo.one(
      from p in Tradewinds.Trade.TraderPosition,
        where: p.port_id == ^port_id and p.good_id == ^good_id,
        preload: [:good]
    )
    |> Repo.ok_or({:trader_position_not_found, good_id})
  end

  @doc """
  Returns the current guild price for a good at a specific port.
  Useful for background systems and price checking.
  """
  def get_guild_price(port_id, good_id) do
    with {:ok, position} <- fetch_position(port_id, good_id) do
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

      {:ok, apply_volatility_jitter(market_price, modifiers.volatility)}
    end
  end

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
         # :ok <- ensure_presence(company, port_id),
         {:ok, position} <- fetch_position(port_id, good_id),
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
         {ask, bid} <-
           quotes(
             final_base_price,
             position.ask_spread,
             position.bid_spread,
             position.stock,
             position.target_stock
           ),
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
             ask_spread: position.ask_spread,
             bid_spread: position.bid_spread,
             timestamp: DateTime.to_iso8601(now)
           },
         token <-
           Phoenix.Token.sign(TradewindsWeb.Endpoint, "trader_quote", quote_data) do
      {:ok, token, quote_data}
    end
  end

  defp ensure_available_stock(
         %Tradewinds.Trade.TraderPosition{stock: stock},
         :buy,
         quantity
       )
       when quantity > stock,
       do: {:error, :insufficient_stock}

  defp ensure_available_stock(_position, _action, _quantity), do: :ok

  # defp ensure_presence(company, port_id) do
  #   if company.home_port_id == port_id or Tradewinds.Fleet.has_ship_at_port?(company.id, port_id) do
  #     :ok
  #   else
  #     {:error, :not_at_port}
  #   end
  # end

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
  def execute_quote(%Tradewinds.Scope{company_id: company_id}, token, destinations)
      when is_list(destinations) do
    with {:ok, quote_data} <- verify_quote(token),
         :ok <- validate_quote_ownership(quote_data, company_id),
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
             # :ok <- ensure_presence(company, port_id),
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

          {ask, bid} =
            quotes(
              final_base_price,
              position.ask_spread,
              position.bid_spread,
              position.stock,
              position.target_stock
            )

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
            ask_spread: position.ask_spread,
            bid_spread: position.bid_spread
          }

          perform_execution(quote_data, position, destinations, now)
        end
      end)
    end
  end

  defp validate_quote_ownership(quote_data, company_id) do
    if quote_data.company_id == company_id, do: :ok, else: {:error, :unauthorized}
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
    Tradewinds.Trade.TraderPosition
    |> where(port_id: ^port_id, good_id: ^good_id)
    |> lock("FOR UPDATE")
    |> preload([:good])
    |> Repo.one()
    |> Repo.ok_or({:market_not_found, good_id})
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
      if quote_data.action == :buy do
        Tradewinds.Economy.calculate_tax_for_port(quote_data.total_price, quote_data.port_id)
      else
        0
      end

    with {:ok, _} <-
           Tradewinds.Companies.record_transaction(
             quote_data.company_id,
             amount,
             :npc_trade,
             :market,
             quote_data.port_id,
             now,
             meta: %{
               trader_id: position.trader_id,
               good_id: quote_data.good_id,
               quantity: quote_data.quantity,
               price: quote_data.unit_price
             }
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

    effective_spread =
      if quote_data.action == :buy, do: position.ask_spread, else: position.bid_spread

    profit_accrued = floor(quote_data.quantity * quote_data.market_price * effective_spread)

    position
    |> Tradewinds.Trade.TraderPosition.changeset(%{
      stock: new_stock,
      quarterly_profit: position.quarterly_profit + profit_accrued
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

    drift = floor(target_stock * effective_supply_rate)
    consumption = floor(current_stock * effective_demand_rate)
    max_stock = target_stock * 3

    new_stock = current_stock + drift - consumption
    clamp(new_stock, 0, max_stock)
  end

  @doc """
  Runs the daily simulation for all positions of a specific trader.
  Applies economic modifiers, computes stock drift/consumption, aggregates player flow, and updates the database.
  """
  def simulate_trader(trader_id, now \\ DateTime.utc_now()) do
    positions =
      Tradewinds.Trade.TraderPosition
      |> where([p], p.trader_id == ^trader_id)
      |> preload(:good)
      |> Repo.all()

    # Look back 1Q for trade volume
    start_time = DateTime.add(now, -51840, :second)

    Repo.transact(fn ->
      results =
        Enum.map(positions, fn position ->
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

          # 2. Target stock is no longer permanently adjusted by player flow.
          # We let current_stock handle the supply/demand curve naturally.
          new_target_stock = position.target_stock

          # 3. Adjust spread based on flow direction
          # Net player buying (negative stock flow):
          #   - Widen ask_spread
          #   - Shrink bid_spread
          # Net player selling (positive stock flow):
          #   - Widen bid_spread
          #   - Shrink ask_spread
          # Stagnant:
          #   - Decay both
          {new_ask_spread, new_bid_spread} =
            cond do
              # Net buying from NPC
              flow < 0 ->
                spread_shift = 0.0004 * abs(flow)

                {
                  min(0.10, position.ask_spread + spread_shift),
                  max(0.015, position.bid_spread - spread_shift)
                }

              # Net selling to NPC
              flow > 0 ->
                spread_shift = 0.0004 * abs(flow)

                {
                  max(0.015, position.ask_spread - spread_shift),
                  min(0.10, position.bid_spread + spread_shift)
                }

              # Stagnant
              true ->
                {
                  max(0.015, position.ask_spread - 0.002),
                  max(0.015, position.bid_spread - 0.002)
                }
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
          |> Tradewinds.Trade.TraderPosition.update_simulation_changeset(%{
            stock: new_stock,
            target_stock: new_target_stock,
            ask_spread: new_ask_spread,
            bid_spread: new_bid_spread
          })
          |> Repo.update!()

          %{
            good_id: position.good_id,
            good_name: position.good.name,
            old_stock: position.stock,
            new_stock: new_stock,
            flow: flow
          }
        end)

      {:ok, results}
    end)
  end

  @doc """
  Resets the quarterly profit for a trader's positions.
  This allows the trader to reassess their stance (e.g., adjust spread) in the future.
  """
  def reset_trader_stances(trader_id) do
    Tradewinds.Trade.TraderPosition
    |> where(trader_id: ^trader_id)
    |> Repo.update_all(set: [quarterly_profit: 0, updated_at: DateTime.utc_now()])

    {:ok, :reset}
  end

  @doc """
  Periodically scans all un-shocked market positions to identify and dynamically correct
  abnormal profit margins. Margins > 60% are squeezed, and Margins < 20% are stretched.
  """
  def balance_arbitrage(now \\ DateTime.utc_now()) do
    goods = Tradewinds.World.list_goods()

    Repo.transact(fn ->
      results =
        Enum.map(goods, fn good ->
          positions =
            Tradewinds.Trade.TraderPosition
            |> where(good_id: ^good.id)
            |> preload(:port)
            |> Repo.all()

          valid_positions =
            Enum.filter(positions, fn pos ->
              modifiers = Tradewinds.Economy.get_active_modifiers(pos.port_id, pos.good_id, now)
              modifiers == %{demand: 1.0, supply: 1.0, price: 1.0, volatility: 1.0}
            end)

          if length(valid_positions) >= 2 do
            quotes =
              Enum.map(valid_positions, fn pos ->
                base_price = good.base_price

                market_price =
                  base_market_price(pos.stock, pos.target_stock, base_price, pos.elasticity)

                {ask, bid} =
                  quotes(
                    market_price,
                    pos.ask_spread,
                    pos.bid_spread,
                    pos.stock,
                    pos.target_stock
                  )

                tax = Tradewinds.Economy.calculate_tax(ask, pos.port.tax_rate_bps)
                true_ask = ask + tax

                %{position: pos, ask: true_ask, bid: bid}
              end)

            cheap_q = Enum.min_by(quotes, & &1.ask)
            expensive_q = Enum.max_by(quotes, & &1.bid)

            if cheap_q.ask > 0 and cheap_q.position.port_id != expensive_q.position.port_id do
              margin = (expensive_q.bid - cheap_q.ask) / cheap_q.ask

              cond do
                margin > 0.80 ->
                  apply_arbitrage_action(
                    cheap_q.position,
                    expensive_q.position,
                    margin,
                    :squeezed
                  )

                margin < 0.30 ->
                  apply_arbitrage_action(
                    cheap_q.position,
                    expensive_q.position,
                    margin,
                    :stretched
                  )

                true ->
                  nil
              end
            end
          end
        end)

      {:ok, results}
    end)
  end

  defp apply_arbitrage_action(cheap_pos, exp_pos, margin, action) do
    {c_target_mod, c_sup_mod, c_dem_mod, e_target_mod, e_sup_mod, e_dem_mod} =
      case action do
        :squeezed -> {1.01, 0.998, 1.002, 0.99, 1.002, 0.998}
        :stretched -> {0.95, 1.01, 0.99, 1.05, 0.99, 1.01}
      end

    c_attrs = %{
      target_stock: max(100, round(cheap_pos.target_stock * c_target_mod)),
      supply_rate: cheap_pos.supply_rate * c_sup_mod,
      demand_rate: cheap_pos.demand_rate * c_dem_mod
    }

    e_attrs = %{
      target_stock: max(100, round(exp_pos.target_stock * e_target_mod)),
      supply_rate: exp_pos.supply_rate * e_sup_mod,
      demand_rate: exp_pos.demand_rate * e_dem_mod
    }

    cheap_changeset =
      Tradewinds.Trade.TraderPosition.update_balancing_changeset(cheap_pos, c_attrs)

    exp_changeset = Tradewinds.Trade.TraderPosition.update_balancing_changeset(exp_pos, e_attrs)

    if cheap_changeset.valid? and exp_changeset.valid? do
      Repo.update!(cheap_changeset)
      Repo.update!(exp_changeset)

      Tradewinds.Trade.ArbitrageLog.changeset(%Tradewinds.Trade.ArbitrageLog{}, %{
        good_id: cheap_pos.good_id,
        cheap_port_id: cheap_pos.port_id,
        expensive_port_id: exp_pos.port_id,
        margin: margin,
        action: to_string(action),
        details: %{
          cheap_port: %{
            old_target: cheap_pos.target_stock,
            new_target: c_attrs.target_stock,
            old_supply: cheap_pos.supply_rate,
            new_supply: c_attrs.supply_rate,
            old_demand: cheap_pos.demand_rate,
            new_demand: c_attrs.demand_rate
          },
          expensive_port: %{
            old_target: exp_pos.target_stock,
            new_target: e_attrs.target_stock,
            old_supply: exp_pos.supply_rate,
            new_supply: e_attrs.supply_rate,
            old_demand: exp_pos.demand_rate,
            new_demand: e_attrs.demand_rate
          }
        }
      })
      |> Repo.insert!()
    end
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
  Baseline noise is +/- 2%. Volatility modifier from shocks is applied.
  """
  def apply_volatility_jitter(market_price, vol_modifier \\ 1.0) do
    # random noise between -2% and +2%
    base_noise = :rand.uniform() * 0.04 - 0.02
    noise = 1.0 + base_noise * vol_modifier
    round(market_price * noise)
  end

  @doc """
  Returns {ask_price, bid_price} based on the final base price and spreads.
  Ask is what the player pays to buy. Bid is what the player receives when selling.
  Applies Phase 3.4 Counterparty bonus based on stock levels relative to target.
  """
  def quotes(final_base_price, ask_spread, bid_spread, current_stock, target_stock) do
    # Counterparty bonus: In the price calculation, after computing ask/bid:
    # - If player is buying and Stock > Target: reduce effective ask_spread by up to 0.03, scaled linearly by (Stock - Target) / Target
    # - If player is selling and Stock < Target: reduce effective bid_spread by up to 0.03, scaled linearly by (Target - Stock) / Target

    effective_ask_spread =
      if current_stock > target_stock do
        bonus = min(0.03, 0.03 * ((current_stock - target_stock) / max(1, target_stock)))
        max(0.015, ask_spread - bonus)
      else
        ask_spread
      end

    effective_bid_spread =
      if current_stock < target_stock do
        bonus = min(0.03, 0.03 * ((target_stock - current_stock) / max(1, target_stock)))
        max(0.015, bid_spread - bonus)
      else
        bid_spread
      end

    ask = floor(final_base_price * (1.0 + effective_ask_spread))
    bid = floor(final_base_price * (1.0 - effective_bid_spread))

    {ask, bid}
  end

  @doc """
  Applies slippage (average impact factor) to a quote price based on the order quantity.
  Uses the average fill price (half the maximum slippage) to reward bulk trading.
  """
  def apply_slippage(:ask, quote_price, order_qty, current_stock) do
    # Buying from NPC: price goes up
    quote_price + div(quote_price * order_qty, 8 * (current_stock + 10))
  end

  def apply_slippage(:bid, quote_price, order_qty, current_stock) do
    # Selling to NPC: price goes down
    div(quote_price * 8 * (current_stock + 10), 8 * (current_stock + 10) + order_qty)
  end

  @doc """
  Clamps the final unit price to not fall below 5% of base price or exceed 1000% of base price.
  """
  def clamp_price(price, base_price) do
    floor_price = floor(base_price * 0.05)
    ceil_price = floor(base_price * 10.0)
    clamp(price, floor_price, ceil_price)
  end

  # Helper for clamping integer boundaries.
  defp clamp(value, min, max) do
    value |> max(min) |> min(max)
  end
end
