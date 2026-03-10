defmodule TradewindsWeb.Schemas.TransferToShipRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TransferToShipRequest",
    description: "Request schema to transfer cargo from a warehouse to a docked ship.",
    type: :object,
    properties: %{
      ship_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      quantity: %Schema{type: :integer, minimum: 1}
    },
    required: [:ship_id, :good_id, :quantity]
  })
end
