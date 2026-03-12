defmodule TradewindsWeb.Schemas.TradersResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "TradersResponse",
    description: "Response schema for a list of traders.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Trader},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
