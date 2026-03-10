defmodule TradewindsWeb.Schemas.GoodsResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GoodsResponse",
    description: "Response schema for a list of goods.",
    type: :object,
    properties: %{
      data: %Schema{type: :array, items: TradewindsWeb.Schemas.Good}
    },
    required: [:data]
  })
end
