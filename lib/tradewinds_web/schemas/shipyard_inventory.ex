defmodule TradewindsWeb.Schemas.ShipyardInventory do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ShipyardInventory",
    description: "An unowned ship available for purchase at a shipyard.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      shipyard_id: %Schema{type: :string, format: :uuid},
      ship_type_id: %Schema{type: :string, format: :uuid},
      ship_id: %Schema{type: :string, format: :uuid},
      cost: %Schema{type: :integer, minimum: 0},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :shipyard_id, :ship_type_id, :ship_id, :cost, :inserted_at, :updated_at]
  })
end
