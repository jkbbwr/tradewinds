defmodule Tradewinds.Shipyard.ShipyardManager do
  @moduledoc """
  Manages shipyard production and inventory.
  """
  use Tradewinds.Manager
  alias Tradewinds.Repo
  alias Tradewinds.Shipyards
  require Logger

  @impl Tradewinds.Manager
  def handle_tick(tick, _gametime, state) when rem(tick, 24) == 0 do
    Logger.info("ShipyardManager: Tick #{tick}. Updating shipyards...")

    Repo.transaction(fn ->
      with {:ok, true} <- Repo.try_advisory_xact_lock(__MODULE__) do
        Logger.info("Acquired shipyard lock. Updating shipyards...")

        for shipyard <- Shipyards.list_shipyards() do
          Shipyards.produce_ships(shipyard)
        end

        {:ok, :processed}
      else
        _ ->
          Logger.info("Shipyard lock held by another process. Skipping.")
          {:ok, :skipped}
      end
    end)

    {:noreply, state}
  end

  @impl Tradewinds.Manager
  def handle_tick(_tick, _gametime, state) do
    {:noreply, state}
  end
end
