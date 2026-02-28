defmodule Tradewinds.ClockTest do
  use Tradewinds.DataCase
  import Mox

  setup :verify_on_exit!

  describe "get_tick/0" do
    test "dispatches to the configured adapter" do
      Tradewinds.ClockMock
      |> expect(:get_tick, fn -> 42 end)

      assert Tradewinds.Clock.get_tick() == 42
    end
  end

  describe "refresh_cache/0" do
    test "dispatches to the configured adapter" do
      Tradewinds.ClockMock
      |> expect(:refresh_cache, fn -> :ok end)

      assert Tradewinds.Clock.refresh_cache() == :ok
    end
  end
end
