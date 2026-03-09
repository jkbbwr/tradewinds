defmodule TradewindsWeb.Schemas.Company do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Company",
    description: "A company directed by a player.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      name: %Schema{type: :string},
      ticker: %Schema{type: :string},
      treasury: %Schema{type: :integer},
      reputation: %Schema{type: :integer},
      status: %Schema{type: :string, enum: ["active", "bankrupt"]},
      home_port_id: %Schema{type: :string, format: :uuid},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:id, :name, :ticker, :treasury, :reputation, :status, :home_port_id]
  })
end
