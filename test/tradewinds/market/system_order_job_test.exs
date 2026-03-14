defmodule Tradewinds.Market.SystemOrderJobTest do
  use Tradewinds.DataCase
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Market.SystemOrderJob
  alias Tradewinds.Market.Order
  alias Tradewinds.Repo

  describe "perform/1" do
    test "successfully posts a system order and schedules the next one" do
      # Setup: Ensure we have at least one port and one good with a guild position
      # These will be in addition to any seeded data
      port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, port: port, good: good, trader: trader)

      # Count existing orders to verify a new one is created
      initial_count = Repo.aggregate(Order, :count)

      # Execute the job
      assert :ok = perform_job(SystemOrderJob, %{})

      # Verify a new order was created
      assert Repo.aggregate(Order, :count) == initial_count + 1

      # Since the job picks a random position, we just verify that there is an open
      # order with a trader_id (skipping the exact ID match if seeded data exists)
      assert Repo.exists?(from o in Order, where: not is_nil(o.trader_id) and o.status == :open)

      # Verify the next job was scheduled
      assert_enqueued worker: SystemOrderJob
    end
  end
end
