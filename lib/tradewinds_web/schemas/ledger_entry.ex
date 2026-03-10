defmodule TradewindsWeb.Schemas.LedgerEntry do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LedgerEntry",
    description: "A financial transaction in a company's ledger.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      company_id: %Schema{type: :string, format: :uuid},
      occurred_at: %Schema{type: :string, format: :"date-time"},
      amount: %Schema{type: :integer},
      reason: %Schema{
        type: :string,
        enum: [
          "initial_deposit",
          "transfer",
          "ship_purchase",
          "tax",
          "market_trade",
          "market_listing_fee",
          "market_penalty_fine",
          "warehouse_upgrade",
          "warehouse_upkeep",
          "ship_upkeep",
          "npc_trade",
          "bailout"
        ]
      },
      reference_type: %Schema{
        type: :string,
        enum: ["market", "ship", "warehouse", "order", "system"]
      },
      reference_id: %Schema{type: :string, format: :uuid},
      idempotency_key: %Schema{type: :string},
      meta: %Schema{type: :object},
      inserted_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [
      :id,
      :company_id,
      :occurred_at,
      :amount,
      :reason,
      :reference_type,
      :reference_id,
      :idempotency_key,
      :inserted_at
    ]
  })
end
