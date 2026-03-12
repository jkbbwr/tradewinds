defmodule TradewindsWeb.Schemas.Port do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Port",
    description: "A port location in the world.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      name: %Schema{type: :string},
      shortcode: %Schema{type: :string},
      country_id: %Schema{type: :string, format: :uuid},
      is_hub: %Schema{type: :boolean},
      tax_rate_bps: %Schema{type: :integer},
      traders: %Schema{type: :array, items: TradewindsWeb.Schemas.Trader},
      outgoing_routes: %Schema{type: :array, items: TradewindsWeb.Schemas.Route},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [
      :id,
      :name,
      :shortcode,
      :country_id,
      :is_hub,
      :tax_rate_bps,
      :inserted_at,
      :updated_at
    ]
  })
end
