defmodule TradewindsWeb.MarketJSON do
  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: order_data(order))}
  end

  def show(%{order: order}) do
    %{data: order_data(order)}
  end

  def blended_price(%{blended_price: price}) do
    %{data: %{blended_price: price}}
  end

  defp order_data(%{order: order}) do
    data(order)
  end

  defp order_data(order) do
    data(order)
  end

  def data(order) do
    %{
      id: order.id,
      company_id: order.company_id,
      port_id: order.port_id,
      good_id: order.good_id,
      side: order.side,
      price: order.price,
      total: order.total,
      remaining: order.remaining,
      status: order.status,
      posted_reputation: order.posted_reputation,
      created_at: order.created_at,
      expires_at: order.expires_at,
      inserted_at: order.inserted_at,
      updated_at: order.updated_at
    }
  end
end
