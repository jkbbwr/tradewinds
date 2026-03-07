defmodule TradewindsWeb.HealthController do
  use TradewindsWeb, :controller

  def show(conn, _params) do
    lag = Tradewinds.get_oban_lag()
    db_active = Tradewinds.db_active?()
    
    conn
    |> put_status(if db_active, do: :ok, else: :service_unavailable)
    |> render(:show, lag_seconds: lag, db_active: db_active)
  end
end
