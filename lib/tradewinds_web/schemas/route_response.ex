defmodule TradewindsWeb.Schemas.RouteResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "RouteResponse",
    description: "Response schema for a single route.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Route
    },
    required: [:data]
  })
end
