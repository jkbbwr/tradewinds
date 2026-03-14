defmodule TradewindsWeb.Schemas.WarehouseInventoryResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "WarehouseInventoryResponse",
    description: "Response schema for a paginated list of warehouse inventory.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.WarehouseInventory},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
