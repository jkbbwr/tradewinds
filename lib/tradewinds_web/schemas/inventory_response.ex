defmodule TradewindsWeb.Schemas.InventoryResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "InventoryResponse",
    description: "Response schema for a shipyard's inventory.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.ShipyardInventory}
    },
    required: [:data]
  })
end
