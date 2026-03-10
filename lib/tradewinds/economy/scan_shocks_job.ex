defmodule Tradewinds.Economy.ScanShocksJob do
  use Oban.Worker, queue: :sweeps

  alias Tradewinds.Economy

  @impl Oban.Worker
  def perform(_job) do
    Economy.scan_shocks()
  end
end
