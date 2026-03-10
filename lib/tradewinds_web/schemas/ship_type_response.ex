defmodule TradewindsWeb.Schemas.ShipTypeResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ShipTypeResponse",
    description: "Response schema for a single ship type.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.ShipType
    },
    required: [:data]
  })
end
