defmodule Tradewinds.Ships.TransitManager do
  use GenServer
  require Logger
  alias Tradewinds.Repo
  alias Tradewinds.Ships
  alias Phoenix.PubSub

  @name {:global, __MODULE__}
  @pubsub Tradewinds.PubSub
  @tick_topic "tick"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @impl true
  def init(state) do
    PubSub.subscribe(@pubsub, @tick_topic)
    Logger.info("TransitManager has started and subscribed to '#{@tick_topic}'.")

    {:ok, state}
  end

  @impl true
  def handle_info({:tick, tick, current_gametime}, state) do
    Logger.info(
      "TransitManager: Tick #{tick}. Gametime: #{current_gametime}. Checking for arrivals..."
    )

    Repo.transact(fn ->
      for ship <- Ships.list_at_sea_ships() do
        if !is_nil(ship.arriving_at) &&
             DateTime.compare(current_gametime, ship.arriving_at) != :lt do
          Logger.info("Ship '#{ship.name}' (ID: #{ship.id}) has arrived at its destination.")
          Ships.ship_arrived(ship)
        end
      end

      {:ok, nil}
    end)

    {:noreply, state}
  end
end
