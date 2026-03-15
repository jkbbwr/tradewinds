defmodule Tradewinds.Trade.BalanceArbitrageJob do
  use Oban.Worker,
    queue: :sweeps,
    unique: [period: 60, states: [:available, :scheduled]]

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Running arbitrage balancer...")

    start_time = System.monotonic_time(:millisecond)
    Tradewinds.Trade.balance_arbitrage()
    end_time = System.monotonic_time(:millisecond)

    Logger.info("Arbitrage balancer completed in #{end_time - start_time}ms")
    :ok
  end
end
