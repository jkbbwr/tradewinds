defmodule TradewindsWeb.Schemas.RegisterResponse do
  require OpenApiSpex
  alias TradewindsWeb.Schemas.Player

  OpenApiSpex.schema(%{
    title: "RegisterResponse",
    description: "Response schema for successful registration",
    type: :object,
    properties: %{
      data: Player
    },
    required: [:data]
  })
end
