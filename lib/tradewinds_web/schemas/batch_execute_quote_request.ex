defmodule TradewindsWeb.Schemas.BatchExecuteQuoteRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BatchExecuteQuoteRequest",
    description: "Request to execute multiple quotes at once.",
    type: :object,
    properties: %{
      requests: %Schema{
        type: :array,
        items: TradewindsWeb.Schemas.ExecuteQuoteRequest
      }
    },
    required: [:requests]
  })
end
