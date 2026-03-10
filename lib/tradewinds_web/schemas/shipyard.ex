defmodule TradewindsWeb.Schemas.Shipyard do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Shipyard",
    description: "A shipyard at a specific port.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      port_id: %Schema{type: :string, format: :uuid},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :port_id, :inserted_at, :updated_at]
  })
end
