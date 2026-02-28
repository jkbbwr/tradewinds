defmodule Tradewinds.Clock do
  @callback get_tick() :: non_neg_integer()
  @callback refresh_cache() :: :ok

  def get_tick, do: impl().get_tick()
  
  def refresh_cache, do: impl().refresh_cache()

  defp impl do
    Application.get_env(:tradewinds, :clock_adapter, Tradewinds.Clock.Live)
  end
end
