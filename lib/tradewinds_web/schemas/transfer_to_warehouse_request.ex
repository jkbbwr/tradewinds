defmodule TradewindsWeb.Schemas.TransferToWarehouseRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TransferToWarehouseRequest",
    description: "Request schema to transfer cargo from a ship to a warehouse.",
    type: :object,
    properties: %{
      warehouse_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      quantity: %Schema{type: :integer, minimum: 1}
    },
    required: [:warehouse_id, :good_id, :quantity]
  })
end
