defmodule TradewindsWeb.AuthController do
  use TradewindsWeb, :controller
  use Goal
  action_fallback TradewindsWeb.FallbackController

  defparams :register do
    required(:uuid, :string, format: :uuid)
  end

  def register(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def login(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def revoke(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end

  def me(conn, _params) do
    send_resp(conn, 501, "Not Implemented")
  end
end
