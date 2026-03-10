defmodule TradewindsWeb.Schemas.ExecuteTradeRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ExecuteTradeRequest",
    description: "Request to execute an immediate trade.",
    type: :object,
    properties: %{
      port_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      action: %Schema{type: :string, enum: ["buy", "sell"]},
      destinations: %Schema{type: :array, items: TradewindsWeb.Schemas.TradeDestination}
    },
    required: [:port_id, :good_id, :action, :destinations]
  })
end
