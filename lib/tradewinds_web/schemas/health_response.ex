defmodule TradewindsWeb.Schemas.HealthResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "HealthResponse",
    description: "Response schema for the health check endpoint",
    type: :object,
    properties: %{
      status: %Schema{type: :string, enum: ["healthy", "degraded", "unhealthy"]},
      database: %Schema{type: :string, enum: ["connected", "disconnected"]},
      oban_lag_seconds: %Schema{type: :integer, minimum: 0},
      server_time: %Schema{type: :string, format: :"date-time"}
    },
    required: [:status, :database, :oban_lag_seconds, :server_time],
    example: %{
      "status" => "healthy",
      "database" => "connected",
      "oban_lag_seconds" => 0,
      "server_time" => "2026-03-08T16:00:00Z"
    }
  })
end
