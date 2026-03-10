defmodule TradewindsWeb.Schemas.PageMetadata do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PageMetadata",
    description: "Pagination metadata for cursor-based paginated results.",
    type: :object,
    properties: %{
      after: %Schema{type: :string, nullable: true},
      before: %Schema{type: :string, nullable: true},
      limit: %Schema{type: :integer, nullable: true}
    }
  })
end
