defmodule Tradewinds.Market.SystemOrderJobTest do
  use Tradewinds.DataCase
  use Oban.Testing, repo: Tradewinds.Repo

  alias Tradewinds.Market.SystemOrderJob
  alias Tradewinds.Market.Order
  alias Tradewinds.Repo

  describe "perform/1" do
    test "successfully posts a system order and schedules the next one" do
      # Cleanup existing data to avoid conflicts
      Repo.delete_all(Order)
      Repo.delete_all(Tradewinds.Trade.TraderPosition)
      Repo.delete_all(Tradewinds.Trade.Trader)

      # Setup: Ensure we have at least one port and one good with a guild position
      port = insert(:port)
      good = insert(:good)
      trader = insert(:trader)
      insert(:trader_position, port: port, good: good, trader: trader)

      # Execute the job
      assert :ok = perform_job(SystemOrderJob, %{})

      # Verify an order was created
      assert order = Repo.one(Order)
      assert order.trader_id == trader.id
      assert order.company_id == nil
      assert order.port_id == port.id
      assert order.good_id == good.id
      assert order.side == :buy
      assert order.status == :open

      # Verify the next job was scheduled
      assert_enqueued worker: SystemOrderJob
    end
  end
end
