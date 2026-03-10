defmodule Tradewinds.Economy.ScanShocksJobTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Economy.ScanShocksJob
  alias Tradewinds.Economy.Shock
  alias Tradewinds.Factory
  alias Tradewinds.Repo

  test "perform/1 transitions pending shocks to active and emits event" do
    now = DateTime.utc_now()
    past = DateTime.add(now, -10, :second)
    future = DateTime.add(now, 10, :second)

    # Should transition
    shock1 = Factory.insert(:shock, status: :pending, start_time: past)
    # Should not transition (in future)
    shock2 = Factory.insert(:shock, status: :pending, start_time: future)

    Phoenix.PubSub.subscribe(Tradewinds.PubSub, "events:world:all")

    assert {:ok, %{started_count: 1, ended_count: 0}} = ScanShocksJob.perform(%Oban.Job{})

    assert Repo.get(Shock, shock1.id).status == :active
    assert Repo.get(Shock, shock2.id).status == :pending

    assert_receive {:message, %{type: "shock_started", data: %{id: id}}}
    assert id == shock1.id
  end

  test "perform/1 transitions active shocks to expired and emits event" do
    now = DateTime.utc_now()
    past = DateTime.add(now, -10, :second)
    future = DateTime.add(now, 10, :second)

    # Should transition
    shock1 = Factory.insert(:shock, status: :active, end_time: past)
    # Should not transition
    shock2 = Factory.insert(:shock, status: :active, end_time: future)
    # Should not transition (no end time)
    shock3 = Factory.insert(:shock, status: :active, end_time: nil)

    Phoenix.PubSub.subscribe(Tradewinds.PubSub, "events:world:all")

    assert {:ok, %{started_count: 0, ended_count: 1}} = ScanShocksJob.perform(%Oban.Job{})

    assert Repo.get(Shock, shock1.id).status == :expired
    assert Repo.get(Shock, shock2.id).status == :active
    assert Repo.get(Shock, shock3.id).status == :active

    assert_receive {:message, %{type: "shock_ended", data: %{id: id}}}
    assert id == shock1.id
  end
end
