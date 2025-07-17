defmodule Tradewinds.World.TaxManager do
  @moduledoc """
  Manages the collection of taxes.
  """
  use Tradewinds.Manager

  @impl Tradewinds.Manager
  def handle_tick(tick, _gametime, state) do
    Logger.info("TaxManager: Tick #{tick}. Applying taxes...")
    # TODO: Implement tax collection logic.
    {:noreply, state}
  end
end