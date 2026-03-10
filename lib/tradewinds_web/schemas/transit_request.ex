defmodule TradewindsWeb.Schemas.TransitRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TransitRequest",
    description: "Request schema to put a ship in transit.",
    type: :object,
    properties: %{
      route_id: %Schema{type: :string, format: :uuid}
    },
    required: [:route_id]
  })
end
