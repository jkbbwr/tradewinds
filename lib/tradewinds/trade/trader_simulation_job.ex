defmodule Tradewinds.Trade.TraderSimulationJob do
  use Oban.Worker,
    queue: :traders,
    unique: [period: 60, states: [:available, :scheduled, :executing]]

  alias Tradewinds.Trade
  alias Tradewinds.Repo

  @game_day_seconds 576

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"trader_id" => trader_id}} = job) do
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_day_seconds, :second)

    Repo.transact(fn ->
      Trade.simulate_trader(trader_id, base_time)

      %{trader_id: trader_id}
      |> new(scheduled_at: next_time)
      |> Oban.insert()
    end)

    :ok
  end
end
