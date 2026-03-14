defmodule TradewindsWeb.Schemas.PassengerResponse do
  require OpenApiSpex

  OpenApiSpex.schema(%{
    title: "PassengerResponse",
    description: "A single passenger record.",
    type: :object,
    properties: %{
      data: TradewindsWeb.Schemas.Passenger
    },
    required: [:data]
  })
end
