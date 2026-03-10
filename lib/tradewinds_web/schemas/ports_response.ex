defmodule TradewindsWeb.Schemas.PortsResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PortsResponse",
    description: "Response schema for a list of ports.",
    type: :object,
    properties: %{
      data: %Schema{type: :array, items: TradewindsWeb.Schemas.Port}
    },
    required: [:data]
  })
end
