defmodule TradewindsWeb.Schemas.LedgerResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "LedgerResponse",
    description: "Response schema for a company's ledger.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.LedgerEntry},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
