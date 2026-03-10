defmodule TradewindsWeb.Schemas.PortResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "PortResponse",
    description: "Response schema for a single port.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Port
    },
    required: [:data]
  })
end
