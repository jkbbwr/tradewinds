defmodule TradewindsWeb.Schemas.BoardPassengerRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BoardPassengerRequest",
    description: "Request to board a passenger group onto a ship.",
    type: :object,
    properties: %{
      ship_id: %Schema{type: :string, format: :uuid, description: "ID of the ship to board onto"}
    },
    required: [:ship_id]
  })
end
