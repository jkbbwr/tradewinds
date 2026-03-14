defmodule Tradewinds.Shipyards.ProductionJobTest do
  use Tradewinds.DataCase, async: true, async: true
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Shipyards.ProductionJob
  alias Tradewinds.Shipyards.Inventory
  alias Tradewinds.Fleet.Ship

  test "perform/1 produces ships and schedules next job" do
    shipyard = insert(:shipyard)
    # Ensure at least one ship type exists
    insert(:ship_type)

    base_time = ~U[2026-03-06 12:00:00Z]
    job = %Oban.Job{args: %{"shipyard_id" => shipyard.id}, scheduled_at: base_time}

    assert :ok = ProductionJob.perform(job)

    # 1. Verify ships were produced (up to 1 per type per week)
    inventory = Repo.all(Inventory)
    assert length(inventory) >= 1

    # Verify ships actually created and unowned
    ships = Repo.all(Ship)
    assert length(ships) >= 1
    assert Enum.all?(ships, fn s -> s.port_id == shipyard.port_id end)
    assert Enum.all?(ships, fn s -> is_nil(s.company_id) end)

    # 2. Verify next job is scheduled (1008 seconds = 1 game week after base_time)
    expected_next_time = DateTime.add(base_time, 1008, :second)

    assert_enqueued(
      worker: ProductionJob,
      args: %{"shipyard_id" => shipyard.id},
      scheduled_at: expected_next_time
    )
  end
end
