defmodule TradewindsWeb.Schemas.QuoteRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "QuoteRequest",
    description: "Request to get a quote from a trader.",
    type: :object,
    properties: %{
      port_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      action: %Schema{type: :string, enum: ["buy", "sell"]},
      quantity: %Schema{type: :integer, minimum: 1}
    },
    required: [:port_id, :good_id, :action, :quantity]
  })
end
