defmodule TradewindsWeb.Schemas.Trader do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "Trader",
    description: "An NPC Trader entity.",
    type: :object,
    properties: %{
      id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      name: %OpenApiSpex.Schema{type: :string},
      inserted_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
      updated_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :name, :inserted_at, :updated_at]
  })
end
