defmodule Tradewinds.Fleet.TransitJobTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Fleet.TransitJob

  test "perform/1 calls dock_ship" do
    route = insert(:route)

    ship =
      insert(:ship,
        status: :traveling,
        port: nil,
        route: route,
        arriving_at: ~U[2026-03-06 00:00:00Z]
      )

    # Note that dock_ship returns {:ok, ship} but TransitJob.perform doesn't currently unwrap it.
    # The job just executes Fleet.dock_ship(ship_id). We can assert the change was made in DB.
    assert {:ok, _} = TransitJob.perform(%Oban.Job{args: %{"ship_id" => ship.id}})

    {:ok, updated_ship} = Tradewinds.Fleet.fetch_ship(ship.id)
    assert updated_ship.status == :docked
    assert updated_ship.port_id == route.to_id
  end
end
