defmodule TradewindsWeb.Schemas.TransitLogsResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "TransitLogsResponse",
    description: "Response schema for a paginated list of transit logs.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.TransitLog},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
