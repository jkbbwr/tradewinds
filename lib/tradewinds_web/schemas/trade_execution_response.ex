defmodule TradewindsWeb.Schemas.TradeExecutionResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TradeExecutionResponse",
    description: "Response from executing a trade.",
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          company_id: %Schema{type: :string, format: :uuid},
          port_id: %Schema{type: :string, format: :uuid},
          good_id: %Schema{type: :string, format: :uuid},
          action: %Schema{type: :string, enum: ["buy", "sell"]},
          quantity: %Schema{type: :integer},
          unit_price: %Schema{type: :integer},
          total_price: %Schema{type: :integer}
        },
        required: [:company_id, :port_id, :good_id, :action, :quantity, :unit_price, :total_price]
      }
    },
    required: [:data]
  })
end
