defmodule Tradewinds.Ships.TransitManager do
  @moduledoc """
  Manages ship transits and arrivals.
  """
  use Tradewinds.Manager
  alias Tradewinds.Repo
  alias Tradewinds.Ships

  @impl Tradewinds.Manager
  def handle_tick(tick, current_gametime, state) do
    Logger.info(
      "TransitManager: Tick #{tick}. Gametime: #{current_gametime}. Checking for arrivals..."
    )

    Repo.transact(fn ->
      with {:ok, true} <- Repo.try_advisory_xact_lock(__MODULE__) do
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
