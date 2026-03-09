defmodule TradewindsWeb.Schemas.CompaniesResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CompaniesResponse",
    description: "Response schema for a list of companies.",
    type: :object,
    properties: %{
      data: %Schema{
        type: :array,
        items: TradewindsWeb.Schemas.Company
      }
    },
    required: [:data]
  })
end
