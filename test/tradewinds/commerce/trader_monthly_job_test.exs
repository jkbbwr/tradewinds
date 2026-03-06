defmodule Tradewinds.Commerce.TraderMonthlyJobTest do
  use Tradewinds.DataCase, async: true
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Commerce.TraderMonthlyJob
  alias Tradewinds.Commerce.TraderPosition

  test "perform/1 resets monthly profit and schedules next job" do
    trader = insert(:trader)
    position1 = insert(:trader_position, trader: trader, monthly_profit: 5000)
    position2 = insert(:trader_position, trader: trader, monthly_profit: 1000)

    base_time = ~U[2026-03-06 12:00:00Z]
    job = %Oban.Job{args: %{"trader_id" => trader.id}, scheduled_at: base_time}

    assert :ok = TraderMonthlyJob.perform(job)

    # 1. Verify monthly profit was reset
    assert Repo.get!(TraderPosition, position1.id).monthly_profit == 0
    assert Repo.get!(TraderPosition, position2.id).monthly_profit == 0

    # 2. Verify next job is scheduled (17280 seconds = 1 game month after base_time)
    expected_next_time = DateTime.add(base_time, 17280, :second)
    
    assert_enqueued(
      worker: TraderMonthlyJob,
      args: %{"trader_id" => trader.id},
      scheduled_at: expected_next_time
    )
  end
end
