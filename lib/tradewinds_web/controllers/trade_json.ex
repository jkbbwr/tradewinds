defmodule TradewindsWeb.TradeJSON do
  def quote(%{token: token, quote_data: quote_data}) do
    %{
      data: %{
        token: token,
        quote: %{
          company_id: quote_data.company_id,
          port_id: quote_data.port_id,
          good_id: quote_data.good_id,
          action: to_string(quote_data.action),
          quantity: quote_data.quantity,
          unit_price: quote_data.unit_price,
          total_price: quote_data.total_price,
          timestamp: quote_data.timestamp
        }
      }
    }
  end

  def execute(%{trade_data: data}) do
    %{
      data: %{
        company_id: data.company_id,
        port_id: data.port_id,
        good_id: data.good_id,
        action: to_string(data.action),
        quantity: data.quantity,
        unit_price: data.unit_price,
        total_price: data.total_price
      }
    }
  end

  def traders(%{page: page}) do
    %{
      data: for(trader <- page.entries, do: trader_data(trader)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  defp trader_data(trader) do
    %{
      id: trader.id,
      name: trader.name,
      inserted_at: trader.inserted_at,
      updated_at: trader.updated_at
    }
  end

  def trader_positions(%{page: page}) do
    %{
      data: for(position <- page.entries, do: position_data(position)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  defp position_data(position) do
    %{
      id: position.id,
      trader_id: position.trader_id,
      port_id: position.port_id,
      good_id: position.good_id,
      stock_bounds: stock_bounds(position.stock),
      price_bounds: price_bounds(position),
      inserted_at: position.inserted_at,
      updated_at: position.updated_at
    }
  end

  defp stock_bounds(0), do: "Out of Stock"
  defp stock_bounds(stock) when stock <= 10, do: "Critically Low"
  defp stock_bounds(stock) when stock <= 50, do: "Low"
  defp stock_bounds(stock) when stock <= 100, do: "Moderate"
  defp stock_bounds(stock) when stock <= 500, do: "Healthy"
  defp stock_bounds(stock) when stock <= 1000, do: "Abundant"
  defp stock_bounds(stock) when stock <= 5000, do: "Very Abundant"
  defp stock_bounds(stock) when stock <= 10000, do: "Massive Stock"
  defp stock_bounds(_), do: "Overflowing"

  defp price_bounds(position) do
    market_price =
      Tradewinds.Trade.base_market_price(
        position.stock,
        position.target_stock,
        position.good.base_price,
        position.elasticity
      )

    ratio = market_price / position.good.base_price

    cond do
      ratio <= 0.25 -> "Dirt Cheap"
      ratio <= 0.5 -> "Very Cheap"
      ratio <= 0.8 -> "Cheap"
      ratio <= 1.2 -> "Average"
      ratio <= 1.5 -> "Expensive"
      ratio <= 2.0 -> "Very Expensive"
      true -> "Exorbitant"
    end
  end
end
