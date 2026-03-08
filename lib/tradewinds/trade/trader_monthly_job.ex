defmodule Tradewinds.Trade.TraderMonthlyJob do
  use Oban.Worker,
    queue: :traders,
    unique: [period: 600, states: [:available, :scheduled, :executing]]

  alias Tradewinds.Trade

  # 1 game month = 30 days = 720 ticks. 1 tick = 24 seconds. 720 * 24 = 17280 seconds.
  @game_month_seconds 17280

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"trader_id" => trader_id}} = job) do
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_month_seconds, :second)

    Trade.reset_trader_stances(trader_id)

    %{trader_id: trader_id}
    |> new(scheduled_at: next_time)
    |> Oban.insert!()

    :ok
  end
end
