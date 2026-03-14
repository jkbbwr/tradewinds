defmodule Tradewinds.Shipyards.ProductionJob do
  use Oban.Worker,
    queue: :shipyard,
    unique: [period: 600, states: [:available, :scheduled]]

  alias Tradewinds.Shipyards
  alias Tradewinds.Repo

  # 1 game week = 7 days = 168 ticks. 1 tick = 24 seconds. 168 * 24 = 4032 seconds.
  @game_week_seconds 1008

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"shipyard_id" => shipyard_id}} = job) do
    Logger.info("Producing ships for shipyard_id: #{shipyard_id}")
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_week_seconds, :second)

    Repo.transact(fn ->
      # Produce ships for this specific shipyard
      case Shipyards.produce_ships(shipyard_id) do
        {:ok, _} ->
          Logger.info("Successfully produced ships for shipyard_id: #{shipyard_id}")

        {:error, reason} ->
          Logger.error(
            "Failed to produce ships for shipyard_id: #{shipyard_id}, reason: #{inspect(reason)}"
          )
      end

      # Schedule next week's production
      %{shipyard_id: shipyard_id}
      |> new(scheduled_at: next_time)
      |> Oban.insert!()

      {:ok, :done}
    end)

    :ok
  end
end
