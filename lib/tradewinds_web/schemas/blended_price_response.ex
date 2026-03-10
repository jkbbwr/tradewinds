defmodule TradewindsWeb.Schemas.BlendedPriceResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BlendedPriceResponse",
    description: "Response schema for a calculated blended price.",
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          blended_price: %Schema{type: :number}
        },
        required: [:blended_price]
      }
    },
    required: [:data]
  })
end
