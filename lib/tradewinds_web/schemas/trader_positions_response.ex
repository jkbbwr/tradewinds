defmodule TradewindsWeb.Schemas.TraderPositionsResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "TraderPositionsResponse",
    description: "Response schema for a list of trader positions.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.TraderPosition},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
