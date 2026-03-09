defmodule TradewindsWeb.Schemas.RegisterRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "RegisterRequest",
    description: "Request schema for player registration",
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      email: %Schema{type: :string, format: :email},
      password: %Schema{type: :string, minLength: 8},
      discord_id: %Schema{type: :string, nullable: true}
    },
    required: [:name, :email, :password],
    example: %{
      "name" => "Kibb",
      "email" => "kibb@example.com",
      "password" => "password123",
      "discord_id" => "1234567890"
    }
  })
end
