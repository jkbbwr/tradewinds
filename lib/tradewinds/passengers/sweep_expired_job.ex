defmodule Tradewinds.Passengers.SweepExpiredJob do
  use Oban.Worker, queue: :sweeps

  alias Tradewinds.Passengers

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Sweeping expired passengers")

    case Passengers.sweep_expired_passengers() do
      {count, nil} ->
        Logger.info("Swept #{count} expired passengers")
        {:ok, %{expired_count: count}}

      error ->
        Logger.error("Failed to sweep expired passengers: #{inspect(error)}")
        error
    end
  end
end
