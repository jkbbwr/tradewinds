defmodule TradewindsWeb.Schemas.CreateWarehouseRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CreateWarehouseRequest",
    description: "Request to purchase a new warehouse.",
    type: :object,
    properties: %{
      port_id: %Schema{type: :string, format: :uuid}
    },
    required: [:port_id]
  })
end
