defmodule TradewindsWeb.Schemas.OrdersResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "OrdersResponse",
    description: "Response schema for a list of market orders.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Order},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
