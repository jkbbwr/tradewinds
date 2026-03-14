defmodule TradewindsWeb.Schemas.PassengersResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PassengersResponse",
    description: "Response schema for a list of passengers.",
    type: :object,
    properties: %{
      data: %Schema{type: :array, items: TradewindsWeb.Schemas.Passenger},
      metadata: TradewindsWeb.Schemas.PageMetadata
    },
    required: [:data, :metadata]
  })
end
