defmodule TradewindsWeb.Schemas.ChangesetResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ChangesetResponse",
    description: "Response schema for validation errors (422 Unprocessable Entity)",
    type: :object,
    properties: %{
      errors: %Schema{
        type: :object,
        description: "A map of field names to lists of error messages",
        additionalProperties: %Schema{
          type: :array,
          items: %Schema{type: :string}
        }
      }
    },
    required: [:errors],
    example: %{
      "errors" => %{
        "email" => ["has invalid format", "has already been taken"],
        "password" => ["should be at least 8 character(s)"]
      }
    }
  })
end
