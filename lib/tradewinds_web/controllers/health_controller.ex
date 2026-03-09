defmodule TradewindsWeb.HealthController do
  use TradewindsWeb, :controller
  use OpenApiSpex.ControllerSpecs
  alias TradewindsWeb.Schemas.HealthResponse

  operation :show,
    summary: "Health Check",
    description:
      "Returns the health status of the application, including database connectivity and Oban job lag.",
    responses: [
      ok: {"Healthy", "application/json", HealthResponse},
      service_unavailable: {"Unhealthy", "application/json", HealthResponse}
    ]

  def show(conn, _params) do
    lag = Tradewinds.get_oban_lag()
    db_active = Tradewinds.db_active?()

    conn
    |> put_status(if db_active, do: :ok, else: :service_unavailable)
    |> render(:show, lag_seconds: lag, db_active: db_active)
  end
end
