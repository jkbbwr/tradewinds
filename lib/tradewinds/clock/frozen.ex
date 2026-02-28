defmodule Tradewinds.Clock.Frozen do
  @behaviour Tradewinds.Clock

  def get_tick, do: 0
  def refresh_cache, do: :ok
end
