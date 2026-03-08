defmodule TradewindsWeb.MarketController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def orders(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def blended_price(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def create_order(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def fill_order(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def delete_order(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
