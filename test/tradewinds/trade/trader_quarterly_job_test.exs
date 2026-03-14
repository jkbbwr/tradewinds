defmodule Tradewinds.Trade.TraderQuarterlyJobTest do
  use Tradewinds.DataCase, async: true
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Trade.TraderQuarterlyJob
  alias Tradewinds.Trade.TraderPosition

  test "perform/1 resets quarterly profit and schedules next job" do
    trader = insert(:trader)
    position1 = insert(:trader_position, trader: trader, quarterly_profit: 5000)
    position2 = insert(:trader_position, trader: trader, quarterly_profit: 1000)

    base_time = ~U[2026-03-06 12:00:00Z]
    job = %Oban.Job{args: %{"trader_id" => trader.id}, scheduled_at: base_time}

    assert :ok = TraderQuarterlyJob.perform(job)

    # 1. Verify quarterly profit was reset
    assert Repo.get!(TraderPosition, position1.id).quarterly_profit == 0
    assert Repo.get!(TraderPosition, position2.id).quarterly_profit == 0

    # 2. Verify next job is scheduled (51840 seconds = 1 game quarter after base_time)
    expected_next_time = DateTime.add(base_time, 51840, :second)

    assert_enqueued(
      worker: TraderQuarterlyJob,
      args: %{"trader_id" => trader.id},
      scheduled_at: expected_next_time
    )
  end
end
