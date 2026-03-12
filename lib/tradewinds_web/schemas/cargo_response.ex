defmodule TradewindsWeb.Schemas.CargoResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CargoResponse",
    description: "Response schema for a list of cargo.",
    type: :object,
    properties: %{
      data: %OpenApiSpex.Schema{type: :array, items: TradewindsWeb.Schemas.Cargo}
    },
    required: [:data]
  })
end
