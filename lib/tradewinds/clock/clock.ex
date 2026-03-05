defmodule Tradewinds.Clock do
  @moduledoc """
  The Clock context.
  Provides a unified interface for the global game time (measured in ticks), 
  supporting both a live simulation clock and a frozen clock for testing.
  """

  @doc """
  Returns the current global game tick as a non-negative integer.
  """
  @callback get_tick() :: non_neg_integer()

  @doc """
  Forces the clock to reload any cached configuration (like the active season) from the database.
  """
  @callback refresh_cache() :: :ok

  @doc """
  Calculates the total number of real-time seconds for a given number of game ticks.
  """
  @callback ticks_to_seconds(ticks :: non_neg_integer()) :: non_neg_integer()

  @doc """
  Delegates `get_tick` to the configured adapter.
  """
  def get_tick, do: impl().get_tick()

  @doc """
  Delegates `refresh_cache` to the configured adapter.
  """
  def refresh_cache, do: impl().refresh_cache()

  @doc """
  Delegates `ticks_to_seconds` to the configured adapter.
  """
  def ticks_to_seconds(ticks), do: impl().ticks_to_seconds(ticks)

  # Determines the active clock adapter from application configuration.
  defp impl do
    Application.get_env(:tradewinds, :clock_adapter, Tradewinds.Clock.Live)
  end
end
