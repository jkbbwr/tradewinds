defmodule TradewindsWeb.WorldController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def ports(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def port(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def goods(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def good(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def ship_types(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def ship_type(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def route(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
