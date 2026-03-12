defmodule Tradewinds.Companies.UpkeepJob do
  use Oban.Worker,
    queue: :company,
    unique: [period: 600, states: [:available, :scheduled]]

  # 1 game month = 30 days = 720 ticks. 1 tick = 24 seconds. 720 * 24 = 17280 seconds.
  @game_month_seconds 17280

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"company_id" => company_id}} = job) do
    Logger.info("Processing upkeep for company_id: #{company_id}")
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_month_seconds, :second)

    # Use the combined monthly upkeep logic that handles ledger entries and bankruptcy
    case Tradewinds.Companies.process_monthly_upkeep(company_id, base_time) do
      {:ok, cost} ->
        Logger.info("Company #{company_id} successfully paid monthly upkeep: #{cost}")

        %{company_id: company_id}
        |> new(scheduled_at: next_time)
        |> Oban.insert!()

        :ok

      {:error, :bankrupt} ->
        Logger.info("Company #{company_id} went bankrupt during monthly upkeep")
        # Still schedule the next month's job even if bankrupt
        %{company_id: company_id}
        |> new(scheduled_at: next_time)
        |> Oban.insert!()

        :ok

      err ->
        Logger.error("Failed to process upkeep for company #{company_id}: #{inspect(err)}")
        err
    end
  end
end
