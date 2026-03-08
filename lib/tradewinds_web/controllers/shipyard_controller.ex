defmodule TradewindsWeb.ShipyardController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def shipyard_for_port(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def inventory(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def purchase(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
