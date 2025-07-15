defmodule Tradewinds.ClockTest do
  use ExUnit.Case, async: true
  alias Tradewinds.Clock

  # The doctests in the module itself provide a great baseline.
  doctest Tradewinds.Clock

  describe "calculate_tick/2" do
    test "returns tick 0 at the exact start time" do
      anchor = ~U[2025-07-16 12:00:00Z]
      now = ~U[2025-07-16 12:00:00Z]
      assert Clock.calculate_tick(anchor, now) == 0
    end

    test "returns tick 0 when less than 15 seconds have passed" do
      anchor = ~U[2025-07-16 12:00:00Z]
      now = ~U[2025-07-16 12:00:14.999Z]
      assert Clock.calculate_tick(anchor, now) == 0
    end

    test "returns tick 1 at exactly 15 seconds" do
      anchor = ~U[2025-07-16 12:00:00Z]
      now = ~U[2025-07-16 12:00:15Z]
      assert Clock.calculate_tick(anchor, now) == 1
    end

    test "calculates a much later tick correctly" do
      anchor = ~U[2025-07-16 12:00:00Z]
      # 10 minutes = 600 seconds. 600 / 15 = 40 ticks.
      now = ~U[2025-07-16 12:10:00Z]
      assert Clock.calculate_tick(anchor, now) == 40
    end
  end

  describe "calculate_gametime/2" do
    test "returns the anchor time for tick 0" do
      anchor = ~U[1625-01-01 08:00:00Z]
      assert Clock.calculate_gametime(anchor, 0) == ~U[1625-01-01 08:00:00Z]
    end

    test "adds one hour for tick 1" do
      anchor = ~U[1625-01-01 08:00:00Z]
      assert Clock.calculate_gametime(anchor, 1) == ~U[1625-01-01 09:00:00Z]
    end

    test "correctly calculates time for a tick that rolls over the day" do
      anchor = ~U[1625-01-01 08:00:00Z]
      # 20 hours later should be 4:00 on the next day
      assert Clock.calculate_gametime(anchor, 20) == ~U[1625-01-02 04:00:00Z]
    end
  end

  describe "tick_to_realtime/2" do
    test "returns the anchor time for tick 0" do
      anchor = ~U[2025-07-16 12:00:00Z]
      assert Clock.tick_to_realtime(anchor, 0) == anchor
    end

    test "returns 15 seconds after the anchor for tick 1" do
      anchor = ~U[2025-07-16 12:00:00Z]
      expected = ~U[2025-07-16 12:00:15Z]
      assert Clock.tick_to_realtime(anchor, 1) == expected
    end

    test "returns the correct time for a much later tick" do
      anchor = ~U[2025-07-16 12:00:00Z]
      # 40 ticks * 15 seconds = 600 seconds = 10 minutes
      expected = ~U[2025-07-16 12:10:00Z]
      assert Clock.tick_to_realtime(anchor, 40) == expected
    end
  end

  describe "calculate_precise_gametime/3" do
    test "returns the anchor time when no time has passed" do
      real_anchor = ~U[2025-07-16 12:00:00Z]
      game_anchor = ~U[1625-01-01 08:00:00Z]
      now = ~U[2025-07-16 12:00:00Z]

      assert Clock.calculate_precise_gametime(real_anchor, game_anchor, now) == game_anchor
    end

    test "calculates time halfway through a tick" do
      real_anchor = ~U[2025-07-16 12:00:00Z]
      game_anchor = ~U[1625-01-01 08:00:00Z]
      # 7.5 real seconds = 0.5 ticks = 30 in-game minutes
      now = DateTime.add(real_anchor, 7.5, :second)

      expected_gametime = DateTime.add(game_anchor, 30, :minute)
      assert Clock.calculate_precise_gametime(real_anchor, game_anchor, now) == expected_gametime
    end

    test "calculates time at the exact boundary of the next tick" do
      real_anchor = ~U[2025-07-16 12:00:00Z]
      game_anchor = ~U[1625-01-01 08:00:00Z]
      # 15 real seconds = 1 tick = 1 in-game hour
      now = DateTime.add(real_anchor, 15, :second)

      expected_gametime = DateTime.add(game_anchor, 1, :hour)
      assert Clock.calculate_precise_gametime(real_anchor, game_anchor, now) == expected_gametime
    end
  end
end
