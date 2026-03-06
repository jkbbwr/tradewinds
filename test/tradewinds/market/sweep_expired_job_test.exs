defmodule Tradewinds.Market.SweepExpiredJobTest do
  use Tradewinds.DataCase, async: true
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Market.SweepExpiredJob
  alias Tradewinds.Market.Order
  alias Tradewinds.Repo

  test "perform/1 expires old open orders" do
    now = DateTime.utc_now()
    yesterday = DateTime.add(now, -1, :day)
    tomorrow = DateTime.add(now, 1, :day)

    # 1. Expired order
    expired = insert(:order, expires_at: yesterday, status: :open)
    
    # 2. Still open order
    open = insert(:order, expires_at: tomorrow, status: :open)

    # 3. Already filled order that was already "expired" in time (should not be touched)
    filled = insert(:order, expires_at: yesterday, status: :filled)

    assert {:ok, %{expired_count: 1}} = SweepExpiredJob.perform(%Oban.Job{})

    # Refresh from DB
    assert Repo.get(Order, expired.id).status == :expired
    assert Repo.get(Order, open.id).status == :open
    assert Repo.get(Order, filled.id).status == :filled
  end
end
