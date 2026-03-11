defmodule Tradewinds.Market.SweepExpiredJob do
  use Oban.Worker, queue: :sweeps

  alias Tradewinds.Market

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Sweeping expired market orders")
    case Market.sweep_expired_orders() do
      {:ok, stats} ->
        Logger.info("Swept #{stats.expired_count} expired market orders")
        {:ok, stats}

      error ->
        Logger.error("Failed to sweep expired market orders: #{inspect(error)}")
        error
    end
  end
end
