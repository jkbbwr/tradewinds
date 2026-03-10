defmodule TradewindsWeb.Schemas.OrdersResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "OrdersResponse",
    description: "Response schema for a list of market orders.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Order}
    },
    required: [:data]
  })
end
