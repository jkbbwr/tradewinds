defmodule TradewindsWeb.Schemas.WarehouseInventory do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "WarehouseInventory",
    description: "An inventory item in a warehouse.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      warehouse_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      quantity: %Schema{type: :integer, minimum: 0}
    },
    required: [:id, :warehouse_id, :good_id, :quantity]
  })
end
