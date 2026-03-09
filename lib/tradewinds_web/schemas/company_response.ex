defmodule TradewindsWeb.Schemas.CompanyResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "CompanyResponse",
    description: "Response schema for a single company.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Company
    },
    required: [:data]
  })
end
