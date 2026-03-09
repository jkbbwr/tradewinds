defmodule TradewindsWeb.Schemas.CreateCompanyRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CreateCompanyRequest",
    description: "Request body for creating a new company.",
    type: :object,
    properties: %{
      name: %Schema{type: :string, minLength: 1},
      ticker: %Schema{type: :string, minLength: 1, maxLength: 5},
      home_port_id: %Schema{type: :string, format: :uuid}
    },
    required: [:name, :ticker, :home_port_id]
  })
end
