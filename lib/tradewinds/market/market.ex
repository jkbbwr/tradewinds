defmodule Tradewinds.Market do
  @moduledoc """
  The Market context for managing the Order Book.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Scope
  alias Tradewinds.Market.Order
  alias Tradewinds.Companies
  alias Tradewinds.Companies.Company
  alias Tradewinds.Logistics

  @base_fee 100
  @listing_expiry_hours 168
  @penalty_fine_rate 0.05
  @penalty_rep_loss -50
  @success_rep_gain 1

  @doc """
  Posts a new order to the order book.
  """
  def post_order(%Scope{company_id: company_id}, port_id, good_id, side, price, total) do
    Repo.transact(fn ->
      with {:ok, company} <- Companies.fetch_company(company_id),
           {:ok, :active} <- Companies.is_active?(company),
           :ok <- check_posting_threshold(company),
           {:ok, order} <- create_order(company, port_id, good_id, side, price, total),
           {:ok, _} <- deduct_listing_fee(company, order.id) do
        Tradewinds.Events.broadcast_order_created(company_id, order)
        {:ok, order}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp create_order(company, port_id, good_id, side, price, total) do
    now = DateTime.utc_now()

    # Assuming @listing_expiry_hours is in game hours, map it to real seconds if needed, or if real time, just add hours.
    # In the new model, 1 game hour = 1 real hour? Or we can just use real hours. Let's add hours.
    expires_at = DateTime.add(now, @listing_expiry_hours, :hour)

    attrs = %{
      company_id: company.id,
      port_id: port_id,
      good_id: good_id,
      side: side,
      price: price,
      total: total,
      created_at: now,
      expires_at: expires_at,
      posted_reputation: company.reputation,
      status: :open
    }

    %Order{}
    |> Order.create_changeset(attrs)
    |> Repo.insert()
  end

  defp deduct_listing_fee(company, order_id) do
    fee = calculate_listing_fee(company)
    now = DateTime.utc_now()

    Companies.record_transaction(
      company.id,
      -fee,
      :market_listing_fee,
      :order,
      order_id,
      now
    )
  end

  @doc """
  Cancels an open order.
  """
  def cancel_order(%Scope{company_id: company_id}, order_id) do
    Repo.transact(fn ->
      with {:ok, order} <- fetch_order_for_update(order_id),
           {:ok, company} <- Companies.fetch_company(company_id),
           {:ok, :active} <- Companies.is_active?(company),
           :ok <- validate_order_ownership(order, company_id),
           :ok <- validate_order_status(order) do
        case order |> Order.update_status_changeset(:cancelled) |> Repo.update() do
          {:ok, updated_order} ->
            Tradewinds.Events.broadcast_order_cancelled(company_id, updated_order)
            {:ok, updated_order}

          error ->
            error
        end
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Fills an order (Taker action).
  """
  def fill_order(%Scope{company_id: taker_company_id}, order_id, quantity) do
    result =
      Repo.transact(fn ->
        with {:ok, taker_company} <- Companies.fetch_company(taker_company_id),
             {:ok, :active} <- Companies.is_active?(taker_company),
             {:ok, order} <- fetch_order_for_update(order_id),
             :ok <- validate_order_status(order),
             :ok <- validate_quantity(order, quantity),
             {:ok, trade_ctx} <- prepare_trade(order, taker_company_id, quantity),
             {:ok, updated_order} <- execute_successful_trade(trade_ctx) do
          {:ok, updated_order}
        else
          {:error, reason} -> Repo.rollback(reason)
        end
      end)

    case result do
      {:ok, updated_order} -> {:ok, updated_order}
      {:error, reason} -> handle_failed_trade(order_id, taker_company_id, quantity, reason)
    end
  end

  defp prepare_trade(order, taker_company_id, quantity) do
    {buyer_id, seller_id} =
      if order.side == :sell do
        {taker_company_id, order.company_id}
      else
        {order.company_id, taker_company_id}
      end

    with {:ok, seller_warehouse} <- Logistics.fetch_warehouse(seller_id, order.port_id),
         {:ok, buyer_warehouse} <- Logistics.fetch_warehouse(buyer_id, order.port_id) do
      trade_ctx = %{
        order: order,
        quantity: quantity,
        buyer_id: buyer_id,
        seller_id: seller_id,
        buyer_warehouse_id: buyer_warehouse.id,
        seller_warehouse_id: seller_warehouse.id,
        total_value: order.price * quantity
      }

      {:ok, trade_ctx}
    end
  end

  defp execute_successful_trade(ctx) do
    now = DateTime.utc_now()
    tax_amount = Tradewinds.Economy.calculate_tax_for_port(ctx.total_value, ctx.order.port_id)

    with {:ok, _} <-
           Companies.record_transaction(
             ctx.buyer_id,
             -ctx.total_value,
             :market_trade,
             :order,
             ctx.order.id,
             now
           ),
         {:ok, _} <-
           (if tax_amount > 0 do
              Companies.record_transaction(
                ctx.buyer_id,
                -tax_amount,
                :tax,
                :order,
                ctx.order.id,
                now,
                meta: %{base_amount: ctx.total_value, port_id: ctx.order.port_id}
              )
            else
              {:ok, :no_tax}
            end),
         {:ok, _} <-
           Companies.record_transaction(
             ctx.seller_id,
             ctx.total_value,
             :market_trade,
             :order,
             ctx.order.id,
             now
           ),
         {:ok, _} <-
           (if tax_amount > 0 do
              Companies.record_transaction(
                ctx.seller_id,
                -tax_amount,
                :tax,
                :order,
                ctx.order.id,
                now,
                meta: %{base_amount: ctx.total_value, port_id: ctx.order.port_id}
              )
            else
              {:ok, :no_tax}
            end),
         {:ok, _} <-
           Logistics.remove_cargo(ctx.seller_warehouse_id, ctx.order.good_id, ctx.quantity),
         {:ok, _} <- Logistics.add_cargo(ctx.buyer_warehouse_id, ctx.order.good_id, ctx.quantity),
         {:ok, _} <- Companies.update_reputation(ctx.buyer_id, @success_rep_gain),
         {:ok, _} <- Companies.update_reputation(ctx.seller_id, @success_rep_gain),
         {:ok, _} <-
           Tradewinds.Economy.log_trade(%{
             occurred_at: now,
             quantity: ctx.quantity,
             price: ctx.order.price,
             source: :market,
             port_id: ctx.order.port_id,
             good_id: ctx.order.good_id,
             buyer_id: ctx.buyer_id,
             seller_id: ctx.seller_id
           }),
         {:ok, updated_order} <- update_order_fulfillment(ctx.order, ctx.quantity) do
      Tradewinds.Events.broadcast_order_filled(ctx.buyer_id, ctx.seller_id, ctx.order, ctx.quantity)
      {:ok, updated_order}
    end
  end

  defp handle_failed_trade(order_id, taker_company_id, quantity, reason) do
    if reason in [:insufficient_inventory, :insufficient_funds, :inventory_not_found] do
      apply_penalties(order_id, taker_company_id, quantity, reason)
    else
      {:error, reason}
    end
  end

  defp apply_penalties(order_id, taker_id, qty, reason) do
    Repo.transact(fn ->
      with {:ok, order} <- fetch_order_for_update(order_id),
           offender_id = determine_offender(order, taker_id, reason),
           fine = calculate_fine(order.price, qty),
           {:ok, _} <-
             Companies.record_transaction(
               offender_id,
               -fine,
               :market_penalty_fine,
               :order,
               order.id,
               DateTime.utc_now()
             ),
           {:ok, _} <- Companies.update_reputation(offender_id, @penalty_rep_loss),
           {:ok, _} <- Repo.delete(order) do
        {:ok, {:trade_voided, reason, offender_id}}
      end
    end)
  end

  defp determine_offender(order, taker_id, reason) do
    buyer_id = if order.side == :sell, do: taker_id, else: order.company_id
    seller_id = if order.side == :sell, do: order.company_id, else: taker_id

    case reason do
      :insufficient_inventory -> seller_id
      :inventory_not_found -> seller_id
      :insufficient_funds -> buyer_id
      _ -> order.company_id
    end
  end

  defp calculate_fine(price, qty), do: max(trunc(price * qty * @penalty_fine_rate), 1)

  @doc """
  Lists open orders for a port and good, sorted by price and reputation.
  """
  def list_orders(port_id, good_id, side, params \\ %{}) do
    order_by_price = if side == :sell, do: :asc, else: :desc

    query =
      Order
      |> where(
        [o],
        o.port_id == ^port_id and o.good_id == ^good_id and o.side == ^side and o.status == :open
      )
      |> join(:inner, [o], c in Company, on: o.company_id == c.id)
      |> select([o, c], %{order: o, company_reputation: c.reputation})

    # Paginator is used when params are present (e.g. from a controller)
    # unless explicitly disabled. Internal calls with no params get the full list.
    if Map.get(params, :paginate, true) and map_size(params) > 0 do
      paginator_opts =
        params
        |> Map.take([:after, :before, :limit])
        |> Map.to_list()
        |> Keyword.merge(cursor_fields: [price: order_by_price, id: :desc], limit: 50)

      query
      |> order_by([o, c], [{^order_by_price, o.price}, desc: o.id])
      |> Repo.paginate(paginator_opts)
    else
      query
      |> order_by([o, c], [{^order_by_price, o.price}, desc: c.reputation])
      |> Repo.all()
    end
  end

  @doc """
  Sweeps expired orders.
  """
  def sweep_expired_orders do
    now = DateTime.utc_now()

    query =
      Order
      |> where([o], o.status == :open and o.expires_at < ^now)
      |> select([o], map(o, [:id, :company_id]))

    {count, expired_orders} =
      Repo.update_all(query, set: [status: :expired, updated_at: now])

    Enum.each(expired_orders, fn order ->
      Tradewinds.Events.broadcast_order_expired(order.company_id, order)
    end)
    
    {:ok, %{expired_count: count}}
  end

  @doc """
  Calculates the blended price for a requested quantity from available orders.
  """
  def calculate_blended_price(port_id, good_id, side, requested_qty) do
    orders = list_orders(port_id, good_id, side)

    {total_cost, remaining} =
      Enum.reduce_while(orders, {0, requested_qty}, fn %{order: order}, {acc_cost, rem_qty} ->
        fill_qty = min(rem_qty, order.remaining)
        new_cost = acc_cost + fill_qty * order.price
        new_rem = rem_qty - fill_qty

        if new_rem <= 0,
          do: {:halt, {new_cost, 0}},
          else: {:cont, {new_cost, new_rem}}
      end)

    filled_qty = requested_qty - remaining

    if filled_qty > 0 do
      {:ok, total_cost / filled_qty}
    else
      {:error, :no_liquidity}
    end
  end

  # Helper functions

  defp fetch_order_for_update(id) do
    Order |> where(id: ^id) |> lock("FOR UPDATE") |> Repo.one() |> Repo.ok_or(:order_not_found)
  end

  defp check_posting_threshold(company) do
    if company.reputation >= 200, do: :ok, else: {:error, :reputation_too_low}
  end

  defp calculate_listing_fee(company) do
    rep = max(company.reputation, 100)
    trunc(@base_fee * (1000 / rep))
  end

  defp validate_order_status(order) do
    if order.status == :open, do: :ok, else: {:error, :order_not_open}
  end

  defp validate_order_ownership(order, company_id) do
    if order.company_id == company_id, do: :ok, else: {:error, :unauthorized_order}
  end

  defp validate_quantity(order, quantity) do
    if quantity > 0 && quantity <= order.remaining, do: :ok, else: {:error, :invalid_quantity}
  end

  defp update_order_fulfillment(order, quantity) do
    new_remaining = order.remaining - quantity
    status = if new_remaining == 0, do: :filled, else: :open

    order
    |> Order.update_remaining_changeset(new_remaining)
    |> Ecto.Changeset.put_change(:status, status)
    |> Repo.update()
  end

  @doc """
  Emits telemetry stats for the Market context.
  """
  def emit_stats do
    stats = %{
      open_orders_count:
        Repo.aggregate(
          from(o in Tradewinds.Market.Order, where: o.status == :open),
          :count,
          :id
        )
    }

    :telemetry.execute([:tradewinds, :market, :stats], stats)
  end
end
