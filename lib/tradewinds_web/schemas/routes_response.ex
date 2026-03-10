defmodule TradewindsWeb.Schemas.RoutesResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "RoutesResponse",
    description: "Response schema for a list of routes.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Route},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
