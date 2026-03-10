defmodule TradewindsWeb.Schemas.Warehouse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Warehouse",
    description: "A warehouse owned by a company.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      level: %Schema{type: :integer},
      capacity: %Schema{type: :integer},
      port_id: %Schema{type: :string, format: :uuid},
      company_id: %Schema{type: :string, format: :uuid},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :level, :capacity, :port_id, :company_id, :inserted_at, :updated_at]
  })
end
