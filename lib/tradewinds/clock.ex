defmodule Tradewinds.Clock do
  @moduledoc """
  Handles time calculations for the game.

  This module is the single source of truth for converting between
  real-world time, game ticks, and the in-game calendar.
  """

  @seconds_per_tick 15
  @in_game_seconds_per_hour 3600
  @in_game_seconds_per_real_second div(@in_game_seconds_per_hour, @seconds_per_tick)

  @doc """
  Calculates the current game tick based on a real-world start time.
  """
  def calculate_tick(%DateTime{} = real_world_anchor, %DateTime{} = now) do
    elapsed_seconds = DateTime.diff(now, real_world_anchor, :second)
    div(elapsed_seconds, @seconds_per_tick)
  end

  @doc """
  Calculates the in-game calendar time from a tick number.
  """
  def calculate_gametime(%DateTime{} = gametime_anchor, tick) when is_integer(tick) do
    DateTime.add(gametime_anchor, tick, :hour)
  end

  @doc """
  Calculates the real-world timestamp for the beginning of a given tick.
  This is the inverse of `calculate_tick/2`.
  """
  def tick_to_realtime(%DateTime{} = real_world_anchor, tick) when is_integer(tick) do
    seconds_to_add = tick * @seconds_per_tick
    DateTime.add(real_world_anchor, seconds_to_add, :second)
  end

  @doc """
  Calculates the precise in-game calendar time based on the real-world time.
  """
  def calculate_precise_gametime(
        %DateTime{} = real_world_anchor,
        %DateTime{} = gametime_anchor,
        %DateTime{} = now
      ) do
    elapsed_real_seconds = DateTime.diff(now, real_world_anchor, :second)
    in_game_seconds_to_add = elapsed_real_seconds * @in_game_seconds_per_real_second
    DateTime.add(gametime_anchor, in_game_seconds_to_add, :second)
  end
end
