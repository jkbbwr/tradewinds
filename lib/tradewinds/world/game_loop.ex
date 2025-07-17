defmodule Tradewinds.GameLoop do
  @moduledoc """
  The main game loop, responsible for publishing ticks.
  """
  use GenServer
  alias Phoenix.PubSub
  alias Tradewinds.Clock
  require Logger

  @name {:global, Tradewinds.GameLoop}
  @pubsub Tradewinds.PubSub
  @tick_topic "tick"

  @doc """
  Starts the GameLoop GenServer.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  @impl true
  def init(opts) do
    realtime_anchor = Keyword.fetch!(opts, :realtime_anchor)
    gametime_anchor = Keyword.fetch!(opts, :gametime_anchor)
    state = %{realtime_anchor: realtime_anchor, gametime_anchor: gametime_anchor}

    schedule_next_tick(state)

    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    now = DateTime.utc_now()
    tick = Clock.calculate_tick(state.realtime_anchor, now)
    gametime = Clock.calculate_gametime(state.gametime_anchor, tick)
    PubSub.broadcast(@pubsub, @tick_topic, {:tick, tick, gametime})

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
