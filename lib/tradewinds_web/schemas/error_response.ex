defmodule TradewindsWeb.Schemas.ErrorResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "ErrorResponse",
    description: "Response schema for standard errors (e.g., 401 Unauthorized)",
    type: :object,
    properties: %{
      errors: %Schema{
        type: :object,
        properties: %{
          detail: %Schema{type: :string}
        },
        required: [:detail]
      }
    },
    required: [:errors],
    example: %{
      "errors" => %{
        "detail" => "Unauthorized"
      }
    }
  })
end
