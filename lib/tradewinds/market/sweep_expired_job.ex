defmodule Tradewinds.Market.SweepExpiredJob do
  use Oban.Worker, queue: :sweeps

  alias Tradewinds.Market

  @impl Oban.Worker
  def perform(_job) do
    {count, _} = Market.sweep_expired_orders()
    {:ok, %{expired_count: count}}
  end
end
