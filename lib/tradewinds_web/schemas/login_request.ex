defmodule TradewindsWeb.Schemas.LoginRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LoginRequest",
    description: "Request schema for player login",
    type: :object,
    properties: %{
      email: %Schema{type: :string, format: :email},
      password: %Schema{type: :string, minLength: 8}
    },
    required: [:email, :password],
    example: %{
      "email" => "kibb@example.com",
      "password" => "password123"
    }
  })
end
