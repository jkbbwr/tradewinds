defmodule Tradewinds.Fleet.TransitJob do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Tradewinds.Fleet

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"ship_id" => ship_id}}) do
    Fleet.dock_ship(ship_id)
  end
end
