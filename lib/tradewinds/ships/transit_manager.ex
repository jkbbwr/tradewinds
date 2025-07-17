defmodule Tradewinds.Ships.TransitManager do
  @moduledoc """
  Manages ship transits and arrivals.
  """
  use GenServer
  require Logger
  alias Tradewinds.Repo
  alias Tradewinds.Ships
  alias Phoenix.PubSub

  @name {:global, __MODULE__}
  @pubsub Tradewinds.PubSub
  @tick_topic "tick"

  @doc """
  Starts the TransitManager GenServer.
  """
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
      with {:ok, true} <- Repo.try_advisory_xact_lock(1) do
        Logger.info("Acquired transit lock. Checking for arrivals...")

        for ship <- Ships.list_at_sea_ships() do
          if !is_nil(ship.arriving_at) &&
               DateTime.compare(current_gametime, ship.arriving_at) != :lt do
            Logger.info("Ship '#{ship.name}' (ID: #{ship.id}) has arrived at its destination.")
            Ships.ship_arrived(ship)
          end
        end

        {:ok, :processed}
      else
        _ ->
          Logger.info("Transit lock held by another process. Skipping.")
          {:ok, :skipped}
      end
    end)

    {:noreply, state}
  end
end
