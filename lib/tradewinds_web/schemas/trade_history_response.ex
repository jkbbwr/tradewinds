defmodule TradewindsWeb.Schemas.TradeHistoryResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "TradeHistoryResponse",
    description: "Response schema for a paginated list of trade history.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.TradeHistoryEntry},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
