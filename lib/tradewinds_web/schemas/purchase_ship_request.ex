defmodule TradewindsWeb.Schemas.PurchaseShipRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PurchaseShipRequest",
    description: "Request schema to purchase a ship from a shipyard.",
    type: :object,
    properties: %{
      ship_type_id: %Schema{type: :string, format: :uuid}
    },
    required: [:ship_type_id]
  })
end
