defmodule Tradewinds.Companies.UpkeepJobTest do
  use Tradewinds.DataCase, async: true, async: true
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Companies.UpkeepJob

  test "perform/1 processes upkeep and schedules next job" do
    company = insert(:company, treasury: 1000)
    # Ship with 500 upkeep
    ship_type = insert(:ship_type, upkeep: 500)
    insert(:ship, company: company, ship_type: ship_type)

    base_time = ~U[2026-03-01 12:00:00Z]
    job = %Oban.Job{args: %{"company_id" => company.id}, scheduled_at: base_time}

    assert :ok = UpkeepJob.perform(job)

    # 1. Verify upkeep was paid
    updated_co = Repo.get!(Tradewinds.Companies.Company, company.id)
    assert updated_co.treasury == 500

    # 2. Verify next job is scheduled (17280 seconds = 1 game month after base_time)
    expected_next_time = DateTime.add(base_time, 17280, :second)

    assert_enqueued(
      worker: UpkeepJob,
      args: %{"company_id" => company.id},
      scheduled_at: expected_next_time
    )
  end
end
