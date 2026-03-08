defmodule TradewindsWeb.TradeController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def quote(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def execute_quote(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def execute(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
