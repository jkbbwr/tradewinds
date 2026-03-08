defmodule TradewindsWeb.WarehouseController do
  use TradewindsWeb, :controller

  action_fallback TradewindsWeb.FallbackController

  def warehouses(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def warehouse(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def grow(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def shrink(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def transfer_to_ship(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
