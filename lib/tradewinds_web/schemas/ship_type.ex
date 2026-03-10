defmodule TradewindsWeb.Schemas.ShipType do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ShipType",
    description: "A class of ship with its static stats.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      name: %Schema{type: :string},
      description: %Schema{type: :string},
      capacity: %Schema{type: :integer},
      speed: %Schema{type: :integer},
      base_price: %Schema{type: :integer},
      upkeep: %Schema{type: :integer},
      passengers: %Schema{type: :integer},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :name, :description, :capacity, :speed, :base_price, :upkeep, :inserted_at, :updated_at]
  })
end
