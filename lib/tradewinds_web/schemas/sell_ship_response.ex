defmodule TradewindsWeb.Schemas.SellShipResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    type: :object,
    properties: %{
      data: %Schema{
        type: :object,
        properties: %{
          price: %Schema{type: :integer, description: "The buy-back price received"}
        }
      }
    },
    example: %{
      data: %{
        price: 2700
      }
    }
  })
end
