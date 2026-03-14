defmodule Tradewinds.Passengers.SpawnJob do
  use Oban.Worker, queue: :default

  alias Tradewinds.Passengers

  require Logger

  @impl Oban.Worker
  def perform(_job) do
    Logger.info("Spawning new passengers")

    Passengers.spawn_passengers()

    {:ok, :spawned}
  end
end
