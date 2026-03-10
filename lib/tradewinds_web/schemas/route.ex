defmodule TradewindsWeb.Schemas.Route do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Route",
    description: "A travel route between two ports.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      distance: %Schema{type: :integer},
      from_id: %Schema{type: :string, format: :uuid},
      to_id: %Schema{type: :string, format: :uuid},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :distance, :from_id, :to_id, :inserted_at, :updated_at]
  })
end
