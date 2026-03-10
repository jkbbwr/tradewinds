defmodule TradewindsWeb.Schemas.ExecuteQuoteRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ExecuteQuoteRequest",
    description: "Request to execute a quote.",
    type: :object,
    properties: %{
      token: %Schema{type: :string},
      destinations: %Schema{type: :array, items: TradewindsWeb.Schemas.TradeDestination}
    },
    required: [:token, :destinations]
  })
end
