defmodule TradewindsWeb.PassengerJSON do
  def index(%{page: page}) do
    %{
      data: for(passenger <- page.entries, do: data(passenger)),
      metadata: %{
        after: page.metadata.after,
        before: page.metadata.before,
        limit: page.metadata.limit
      }
    }
  end

  def show(%{passenger: passenger}) do
    %{data: data(passenger)}
  end

  defp data(passenger) do
    %{
      id: passenger.id,
      count: passenger.count,
      bid: passenger.bid,
      status: passenger.status,
      expires_at: passenger.expires_at,
      ship_id: passenger.ship_id,
      origin_port_id: passenger.origin_port_id,
      destination_port_id: passenger.destination_port_id,
      inserted_at: passenger.inserted_at,
      updated_at: passenger.updated_at
    }
  end
end
