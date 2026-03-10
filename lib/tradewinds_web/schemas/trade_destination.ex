defmodule TradewindsWeb.Schemas.TradeDestination do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TradeDestination",
    description: "A destination for a trade.",
    type: :object,
    properties: %{
      type: %Schema{type: :string, enum: ["ship", "warehouse"]},
      id: %Schema{type: :string, format: :uuid},
      quantity: %Schema{type: :integer, minimum: 1}
    },
    required: [:type, :id, :quantity]
  })
end
