defmodule TradewindsWeb.Schemas.WarehouseResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "WarehouseResponse",
    description: "Response schema for a single warehouse.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Warehouse
    },
    required: [:data]
  })
end
