defmodule TradewindsWeb.Schemas.CreateOrderRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CreateOrderRequest",
    description: "Request schema to create a new market order.",
    type: :object,
    properties: %{
      port_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      side: %Schema{type: :string, enum: ["buy", "sell"]},
      price: %Schema{type: :integer, minimum: 1},
      total: %Schema{type: :integer, minimum: 1}
    },
    required: [:port_id, :good_id, :side, :price, :total]
  })
end
