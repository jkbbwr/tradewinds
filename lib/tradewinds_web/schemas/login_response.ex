defmodule TradewindsWeb.Schemas.LoginResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LoginResponse",
    description: "Response schema for successful login, returning a JWT token",
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          token: %Schema{
            type: :string,
            description: "Authentication token to be used in Authorization header"
          }
        },
        required: [:token]
      }
    },
    required: [:data]
  })
end
