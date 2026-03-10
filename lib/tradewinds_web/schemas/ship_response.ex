defmodule TradewindsWeb.Schemas.ShipResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ShipResponse",
    description: "Response schema for a single ship.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Ship
    },
    required: [:data]
  })
end
