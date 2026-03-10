defmodule TradewindsWeb.Schemas.QuoteResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "QuoteResponse",
    description: "A quote from a trader.",
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          token: %Schema{type: :string},
          quote: %Schema{
            type: :object,
            properties: %{
              company_id: %Schema{type: :string, format: :uuid},
              port_id: %Schema{type: :string, format: :uuid},
              good_id: %Schema{type: :string, format: :uuid},
              action: %Schema{type: :string, enum: ["buy", "sell"]},
              quantity: %Schema{type: :integer},
              unit_price: %Schema{type: :integer},
              total_price: %Schema{type: :integer},
              timestamp: %Schema{type: :string, format: :"date-time"}
            },
            required: [:company_id, :port_id, :good_id, :action, :quantity, :unit_price, :total_price, :timestamp]
          }
        },
        required: [:token, :quote]
      }
    },
    required: [:data]
  })
end
