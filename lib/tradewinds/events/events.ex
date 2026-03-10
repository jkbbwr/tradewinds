defmodule Tradewinds.Events do
  @moduledoc """
  The Events context.
  Centralizes PubSub broadcasting for different domain events to keep the core contexts clean.
  """

  alias Phoenix.PubSub

  @pubsub Tradewinds.PubSub

  defp topic(company_id), do: "events:#{company_id}:all"

  def broadcast_ledger_entry(company_id, ledger) do
    PubSub.broadcast(
      @pubsub,
      topic(company_id),
      {:message,
       %{
         type: "ledger_entry",
         data: %{
           id: ledger.id,
           amount: ledger.amount,
           reason: ledger.reason,
           reference_type: ledger.reference_type,
           reference_id: ledger.reference_id,
           occurred_at: ledger.occurred_at
         }
       }}
    )
  end

  def broadcast_ship_transit_started(company_id, ship) do
    PubSub.broadcast(
      @pubsub,
      topic(company_id),
      {:message,
       %{
         type: "ship_transit_started",
         data: %{
           ship_id: ship.id,
           route_id: ship.route_id,
           arriving_at: ship.arriving_at
         }
       }}
    )
  end

  def broadcast_ship_docked(company_id, ship) do
    PubSub.broadcast(
      @pubsub,
      topic(company_id),
      {:message,
       %{
         type: "ship_docked",
         data: %{
           ship_id: ship.id,
           port_id: ship.port_id
         }
       }}
    )
  end

  def broadcast_order_created(company_id, order) do
    PubSub.broadcast(
      @pubsub,
      topic(company_id),
      {:message,
       %{
         type: "order_created",
         data: %{
           id: order.id,
           side: order.side,
           good_id: order.good_id,
           price: order.price,
           total: order.total
         }
       }}
    )
  end

  def broadcast_order_cancelled(company_id, order) do
    PubSub.broadcast(
      @pubsub,
      topic(company_id),
      {:message, %{type: "order_cancelled", data: %{id: order.id}}}
    )
  end

  def broadcast_order_filled(buyer_id, seller_id, order, quantity) do
    PubSub.broadcast(
      @pubsub,
      topic(buyer_id),
      {:message,
       %{
         type: "order_filled",
         data: %{id: order.id, role: "buyer", quantity: quantity, price: order.price}
       }}
    )

    PubSub.broadcast(
      @pubsub,
      topic(seller_id),
      {:message,
       %{
         type: "order_filled",
         data: %{id: order.id, role: "seller", quantity: quantity, price: order.price}
       }}
    )
  end

  def broadcast_order_expired(company_id, order) do
    PubSub.broadcast(
      @pubsub,
      topic(company_id),
      {:message, %{type: "order_expired", data: %{id: order.id}}}
    )
  end

  def broadcast_shock_started(shock) do
    PubSub.broadcast(
      @pubsub,
      "events:world:all",
      {:message, %{
        type: "shock_started",
        data: %{
          id: shock.id,
          name: shock.name,
          description: shock.description,
          port_id: shock.port_id,
          good_id: shock.good_id
        }
      }}
    )
  end

  def broadcast_shock_ended(shock) do
    PubSub.broadcast(
      @pubsub,
      "events:world:all",
      {:message, %{
        type: "shock_ended",
        data: %{
          id: shock.id,
          name: shock.name,
          port_id: shock.port_id,
          good_id: shock.good_id
        }
      }}
    )
  end
end
