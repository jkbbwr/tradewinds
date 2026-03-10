defmodule TradewindsWeb.Schemas.OrderResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "OrderResponse",
    description: "Response schema for a single market order.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Order
    },
    required: [:data]
  })
end
