defmodule Tradewinds.Fleet.TransitJob do
  use Oban.Worker, queue: :transit, max_attempts: 3, unique: true

  alias Tradewinds.Fleet

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"ship_id" => ship_id}}) do
    Fleet.dock_ship(ship_id)
  end
end
