defmodule TradewindsWeb.Schemas.ShipsResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "ShipsResponse",
    description: "Response schema for a list of ships.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Ship}
    },
    required: [:data]
  })
end
