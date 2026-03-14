defmodule TradewindsWeb.Schemas.TradeHistoryEntry do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "TradeHistoryEntry",
    description: "A single trade execution log entry.",
    type: :object,
    properties: %{
      id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      occurred_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
      quantity: %OpenApiSpex.Schema{type: :integer},
      price: %OpenApiSpex.Schema{type: :integer},
      source: %OpenApiSpex.Schema{
        type: :string,
        enum: ["market", "npc_trader", "contract_execution"]
      },
      buyer_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      seller_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      port_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
      good_id: %OpenApiSpex.Schema{type: :string, format: :uuid}
    },
    required: [
      :id,
      :occurred_at,
      :quantity,
      :price,
      :source,
      :buyer_id,
      :seller_id,
      :port_id,
      :good_id
    ]
  })
end
