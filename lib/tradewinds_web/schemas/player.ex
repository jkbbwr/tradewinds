defmodule TradewindsWeb.Schemas.Player do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Player",
    description: "A player in the system",
    type: :object,
    properties: %{
      id: %Schema{type: :integer, description: "The player ID"},
      name: %Schema{type: :string, description: "The player's name"},
      email: %Schema{type: :string, format: :email, description: "The player's email"},
      discord_id: %Schema{type: :string, description: "The player's Discord ID", nullable: true},
      enabled: %Schema{type: :boolean, description: "Whether the player account is enabled"},
      inserted_at: %Schema{
        type: :string,
        format: :"date-time",
        description: "When the player was created"
      }
    },
    required: [:id, :name, :email, :enabled, :inserted_at],
    example: %{
      "id" => 1,
      "name" => "Kibb",
      "email" => "kibb@example.com",
      "discord_id" => "1234567890",
      "enabled" => true,
      "inserted_at" => "2026-03-08T16:00:00Z"
    }
  })
end
