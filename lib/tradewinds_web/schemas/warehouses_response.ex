defmodule TradewindsWeb.Schemas.WarehousesResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "WarehousesResponse",
    description: "Response schema for a list of warehouses.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Warehouse},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
