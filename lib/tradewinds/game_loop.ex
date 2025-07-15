defmodule Tradewinds.GameLoop do
  use GenServer
  alias Phoenix.PubSub
  alias Tradewinds.Clock

  @name {:global, Tradewinds.GameLoop}

  def start(opts) do
    GenServer.start(__MODULE__, opts, name: @name)
  end

  @impl true
  def init(opts) do
    realtime_anchor = Keyword.fetch!(opts, :realtime_anchor)
    state = %{realtime_anchor: realtime_anchor}
    schedule_next_tick(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, %{realtime_anchor: realtime_anchor} = state) do
    tick = Clock.calculate_tick(realtime_anchor, DateTime.utc_now())
    PubSub.broadcast(Tradewinds.PubSub, "gametick", {:tick, tick})
    schedule_next_tick(state)
    {:noreply, state}
  end

  defp schedule_next_tick(%{realtime_anchor: realtime_anchor}) do
    now = DateTime.utc_now()
    current_tick = Clock.calculate_tick(realtime_anchor, now)

    next_tick_timestamp =
      Clock.tick_to_realtime(realtime_anchor, current_tick + 1)

    milliseconds_to_wait = DateTime.diff(next_tick_timestamp, now, :millisecond)
    delay = max(0, milliseconds_to_wait)
    Process.send_after(self(), :tick, delay)
  end
end
