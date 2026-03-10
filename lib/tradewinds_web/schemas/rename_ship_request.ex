defmodule TradewindsWeb.Schemas.RenameShipRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "RenameShipRequest",
    description: "Request schema to rename a ship.",
    type: :object,
    properties: %{
      name: %Schema{type: :string}
    },
    required: [:name]
  })
end
