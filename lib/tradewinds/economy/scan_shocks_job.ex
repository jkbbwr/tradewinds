defmodule Tradewinds.Economy.ScanShocksJob do
  use Oban.Worker, queue: :sweeps

  alias Tradewinds.Economy

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Scanning economy shocks")

    case Economy.scan_shocks() do
      {:ok, stats} ->
        Logger.info(
          "Economy shocks scan complete. Started: #{stats.started_count}, Ended: #{stats.ended_count}"
        )

        {:ok, stats}

      error ->
        Logger.error("Failed to scan economy shocks: #{inspect(error)}")
        error
    end
  end
end
