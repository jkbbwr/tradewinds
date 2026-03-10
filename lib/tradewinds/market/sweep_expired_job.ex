defmodule Tradewinds.Market.SweepExpiredJob do
  use Oban.Worker, queue: :sweeps

  alias Tradewinds.Market

  @impl Oban.Worker
  def perform(_job) do
    Market.sweep_expired_orders()
  end
end
