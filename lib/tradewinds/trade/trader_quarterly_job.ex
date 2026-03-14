defmodule Tradewinds.Trade.TraderQuarterlyJob do
  use Oban.Worker,
    queue: :traders,
    unique: [period: 600, states: [:available, :scheduled]]

  alias Tradewinds.Trade

  # 1 game month = 30 days = 720 ticks. 1 tick = 24 seconds. 720 * 24 = 17280 seconds.
  @game_quarter_seconds 51840

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"trader_id" => trader_id}} = job) do
    Logger.info("Running quarterly job for trader_id: #{trader_id}")
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_quarter_seconds, :second)

    {:ok, :reset} = Trade.reset_trader_stances(trader_id)
    Logger.info("Successfully reset stances for trader_id: #{trader_id}")

    %{trader_id: trader_id}
    |> new(scheduled_at: next_time)
    |> Oban.insert!()

    :ok
  end
end
