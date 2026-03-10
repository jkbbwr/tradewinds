defmodule TradewindsWeb.Schemas.GoodResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "GoodResponse",
    description: "Response schema for a single good.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Good
    },
    required: [:data]
  })
end
