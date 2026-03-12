defmodule TradewindsWeb.Schemas.BatchQuoteRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BatchQuoteRequest",
    description: "Request to get multiple quotes at once.",
    type: :object,
    properties: %{
      requests: %Schema{
        type: :array,
        items: TradewindsWeb.Schemas.QuoteRequest
      }
    },
    required: [:requests]
  })
end
