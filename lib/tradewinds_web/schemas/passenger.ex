defmodule TradewindsWeb.Schemas.Passenger do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Passenger",
    description: "A passenger group request or boarded group.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      count: %Schema{type: :integer},
      bid: %Schema{type: :integer},
      status: %Schema{type: :string, enum: ["available", "boarded"]},
      expires_at: %Schema{type: :string, format: :"date-time"},
      ship_id: %Schema{type: :string, format: :uuid, nullable: true},
      origin_port_id: %Schema{type: :string, format: :uuid},
      destination_port_id: %Schema{type: :string, format: :uuid},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [
      :id,
      :count,
      :bid,
      :status,
      :expires_at,
      :origin_port_id,
      :destination_port_id,
      :inserted_at,
      :updated_at
    ]
  })
end
