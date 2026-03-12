defmodule TradewindsWeb.Schemas.TransitLog do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TransitLog",
    description: "A log of a ship's transit between ports.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      departed_at: %Schema{type: :string, format: :"date-time"},
      arrived_at: %Schema{type: :string, format: :"date-time", nullable: true},
      ship_id: %Schema{type: :string, format: :uuid},
      route_id: %Schema{type: :string, format: :uuid}
    },
    required: [:id, :departed_at, :ship_id, :route_id]
  })
end
