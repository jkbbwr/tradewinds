defmodule TradewindsWeb.Schemas.BatchExecuteQuoteResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BatchExecuteQuoteResponse",
    description: "A list of quote execution responses or errors.",
    type: :object,
    properties: %{
      data: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          properties: %{
            status: %Schema{type: :string, enum: ["success", "error"]},
            token: %Schema{type: :string},
            message: %Schema{type: :string},
            execution: %Schema{
              type: :object,
              properties: %{
                company_id: %Schema{type: :string, format: :uuid},
                port_id: %Schema{type: :string, format: :uuid},
                good_id: %Schema{type: :string, format: :uuid},
                action: %Schema{type: :string, enum: ["buy", "sell"]},
                quantity: %Schema{type: :integer},
                unit_price: %Schema{type: :integer},
                total_price: %Schema{type: :integer}
              }
            }
          },
          required: [:status]
        }
      }
    },
    required: [:data]
  })
end
