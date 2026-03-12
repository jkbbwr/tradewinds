defmodule TradewindsWeb.Schemas.Cargo do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Cargo",
    description: "Cargo loaded on a ship or stored in a warehouse.",
    type: :object,
    properties: %{
      good_id: %Schema{type: :string, format: :uuid},
      quantity: %Schema{type: :integer}
    },
    required: [:good_id, :quantity]
  })
end
