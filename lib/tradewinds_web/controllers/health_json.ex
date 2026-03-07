defmodule TradewindsWeb.HealthJSON do
  def show(%{lag_seconds: lag_seconds, db_active: db_active}) do
    %{
      status: if(lag_seconds > 60 or not db_active, do: "degraded", else: "healthy"),
      database: if(db_active, do: "connected", else: "disconnected"),
      oban_lag_seconds: lag_seconds,
      server_time: DateTime.utc_now()
    }
  end
end
