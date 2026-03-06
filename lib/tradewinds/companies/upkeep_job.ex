defmodule Tradewinds.Companies.UpkeepJob do
  use Oban.Worker,
    queue: :default,
    unique: [period: 600, states: [:available, :scheduled, :executing]]

  # 1 game month = 30 days = 720 ticks. 1 tick = 24 seconds. 720 * 24 = 17280 seconds.
  @game_month_seconds 17280

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"company_id" => company_id}} = job) do
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_month_seconds, :second)

    # Use the combined monthly upkeep logic that handles ledger entries and bankruptcy
    case Tradewinds.Companies.process_monthly_upkeep(company_id, base_time) do
      {:ok, _} ->
        %{company_id: company_id}
        |> new(scheduled_at: next_time)
        |> Oban.insert!()
        :ok

      {:error, :bankrupt} ->
        # Still schedule the next month's job even if bankrupt
        %{company_id: company_id}
        |> new(scheduled_at: next_time)
        |> Oban.insert!()
        :ok

      err ->
        err
    end
  end
end
