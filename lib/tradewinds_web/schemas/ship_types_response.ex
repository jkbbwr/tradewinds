defmodule TradewindsWeb.Schemas.ShipTypesResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ShipTypesResponse",
    description: "Response schema for a list of ship types.",
    type: :object,
    properties: %{
      data: %Schema{type: :array, items: TradewindsWeb.Schemas.ShipType}
    },
    required: [:data]
  })
end
