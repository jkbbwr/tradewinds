defmodule Tradewinds.Fleet.TransitJob do
  use Oban.Worker,
    queue: :transit,
    max_attempts: 5

  alias Tradewinds.Fleet

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"ship_id" => ship_id}}) do
    Logger.info("Processing transit for ship_id: #{ship_id}")

    case Fleet.dock_ship(ship_id) do
      {:ok, ship} ->
        Logger.info("Ship #{ship_id} successfully docked at port_id: #{ship.port_id}")
        {:ok, ship}

      {:error, reason} ->
        Logger.error("Failed to dock ship #{ship_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
