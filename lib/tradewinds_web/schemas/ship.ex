defmodule TradewindsWeb.Schemas.Ship do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Ship",
    description: "A ship owned by a company.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      name: %Schema{type: :string},
      status: %Schema{type: :string, enum: ["docked", "traveling"]},
      arriving_at: %Schema{type: :string, format: :"date-time", nullable: true},
      company_id: %Schema{type: :string, format: :uuid},
      ship_type_id: %Schema{type: :string, format: :uuid},
      port_id: %Schema{type: :string, format: :uuid, nullable: true},
      route_id: %Schema{type: :string, format: :uuid, nullable: true},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :name, :status, :company_id, :ship_type_id, :inserted_at, :updated_at]
  })
end
