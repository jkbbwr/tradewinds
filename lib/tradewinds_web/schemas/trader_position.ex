defmodule TradewindsWeb.Schemas.TraderPosition do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TraderPosition",
    description: "An NPC trader's position for a specific good at a port.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      trader_id: %Schema{type: :string, format: :uuid},
      port_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      stock_bounds: %Schema{type: :string},
      price_bounds: %Schema{type: :string},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :trader_id, :port_id, :good_id, :stock_bounds, :price_bounds, :inserted_at, :updated_at]
  })
end
