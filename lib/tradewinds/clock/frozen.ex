defmodule Tradewinds.Clock.Frozen do
  @moduledoc """
  A frozen clock adapter used primarily for testing, returning a static tick.
  """
  @behaviour Tradewinds.Clock

  @impl true
  @doc """
  Always returns 0 for testing stability.
  """
  def get_tick, do: 0

  @impl true
  @doc """
  Always returns 0 for testing stability.
  """
  def ticks_to_seconds(_ticks), do: 0

  @impl true
  @doc """
  A no-op for the frozen clock.
  """
  def refresh_cache, do: :ok
end
