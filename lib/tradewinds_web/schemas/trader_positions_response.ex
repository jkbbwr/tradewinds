defmodule TradewindsWeb.Schemas.TraderPositionsResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TraderPositionsResponse",
    description: "Response schema for a list of trader positions.",
    type: :object,
    properties: %{
      data: %Schema{type: :array, items: TradewindsWeb.Schemas.TraderPosition}
    },
    required: [:data]
  })
end
