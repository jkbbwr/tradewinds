defmodule TradewindsWeb.Schemas.CompanyEconomyResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CompanyEconomyResponse",
    description: "Response schema for company economy summary.",
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          treasury: %Schema{type: :integer},
          reputation: %Schema{type: :integer},
          ship_upkeep: %Schema{type: :integer},
          warehouse_upkeep: %Schema{type: :integer},
          total_upkeep: %Schema{type: :integer}
        },
        required: [:treasury, :reputation, :ship_upkeep, :warehouse_upkeep, :total_upkeep]
      }
    },
    required: [:data]
  })
end
