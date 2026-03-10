defmodule TradewindsWeb.Schemas.PortsResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "PortsResponse",
    description: "Response schema for a list of ports.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Port},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
