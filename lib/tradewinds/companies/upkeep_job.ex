defmodule Tradewinds.Companies.UpkeepJob do
  use Oban.Worker,
    queue: :default,
    unique: [period: 600, states: [:available, :scheduled, :executing]]

  alias Tradewinds.{Fleet, Logistics}
  alias Tradewinds.Repo

  # 1 game month = 30 days = 720 ticks. 1 tick = 24 seconds. 720 * 24 = 17280 seconds.
  @game_month_seconds 17280

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"company_id" => company_id}} = job) do
    base_time = job.scheduled_at || job.inserted_at
    next_time = DateTime.add(base_time, @game_month_seconds, :second)

    Repo.transact(fn ->
      with {:ok, _} <- Logistics.process_upkeep(company_id, base_time),
           {:ok, _} <- Fleet.process_upkeep(company_id, base_time) do
        %{company_id: company_id}
        |> new(scheduled_at: next_time)
        |> Oban.insert()
      end
    end)
  end
end
