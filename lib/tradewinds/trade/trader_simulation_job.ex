defmodule Tradewinds.Trade.TraderSimulationJob do
  use Oban.Worker,
    queue: :traders,
    unique: [period: 60, states: [:available, :scheduled]]

  alias Tradewinds.Trade
  alias Tradewinds.Repo

  @game_day_seconds 4320

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"trader_id" => trader_id}} = job) do
    Logger.info("Simulating trader_id: #{trader_id}")
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_day_seconds, :second)

    Repo.transact(fn ->
      case Trade.simulate_trader(trader_id, base_time) do
        {:ok, results} ->
          summary =
            Enum.map_join(results, ", ", fn r ->
              "#{r.good_name}: #{r.old_stock}->#{r.new_stock} (flow: #{r.flow})"
            end)

          Logger.info("Successfully simulated trader_id: #{trader_id}. #{summary}")

        {:error, reason} ->
          Logger.error("Failed to simulate trader_id: #{trader_id}, reason: #{inspect(reason)}")
      end

      %{trader_id: trader_id}
      |> new(scheduled_at: next_time)
      |> Oban.insert()
    end)

    :ok
  end
end
