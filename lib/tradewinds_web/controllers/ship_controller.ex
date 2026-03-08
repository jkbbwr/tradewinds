defmodule TradewindsWeb.ShipController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def ships(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def ship(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def rename_ship(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def transit(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def transfer_to_warehouse(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
