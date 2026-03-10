defmodule TradewindsWeb.Schemas.Order do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Order",
    description: "An order on the market.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      company_id: %Schema{type: :string, format: :uuid},
      port_id: %Schema{type: :string, format: :uuid},
      good_id: %Schema{type: :string, format: :uuid},
      side: %Schema{type: :string, enum: ["buy", "sell"]},
      price: %Schema{type: :integer},
      total: %Schema{type: :integer},
      remaining: %Schema{type: :integer},
      status: %Schema{type: :string, enum: ["open", "filled", "cancelled", "expired"]},
      posted_reputation: %Schema{type: :integer},
      created_at: %Schema{type: :string, format: :"date-time"},
      expires_at: %Schema{type: :string, format: :"date-time"},
      inserted_at: %Schema{type: :string, format: :"date-time"},
      updated_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [
      :id,
      :company_id,
      :port_id,
      :good_id,
      :side,
      :price,
      :total,
      :remaining,
      :status,
      :posted_reputation,
      :created_at,
      :expires_at,
      :inserted_at,
      :updated_at
    ]
  })
end
