defmodule TradewindsWeb.Schemas.SellShipRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    type: :object,
    properties: %{
      ship_id: %Schema{type: :string, format: :uuid, description: "Ship ID to sell"}
    },
    required: [:ship_id],
    example: %{
      ship_id: "7488a646-e31f-495c-ad5d-7538bc100574"
    }
  })
end
