defmodule TradewindsWeb.Schemas.ShipyardResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ShipyardResponse",
    description: "Response schema for a single shipyard.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Shipyard
    },
    required: [:data]
  })
end
