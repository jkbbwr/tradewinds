defmodule TradewindsWeb.Schemas.FillOrderRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "FillOrderRequest",
    description: "Request schema to fill an existing market order.",
    type: :object,
    properties: %{
      quantity: %Schema{type: :integer, minimum: 1}
    },
    required: [:quantity]
  })
end
