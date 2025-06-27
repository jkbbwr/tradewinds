defmodule Tradewinds.Trading do
  @moduledoc """
  The Trading context.
  Encapsulates the primary game loop of trade, managing ships, cargo, and markets.
  """

  alias Tradewinds.Repo
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Item
  alias Tradewinds.Schema.ShipInventory
  alias Tradewinds.Schema.Warehouse
  alias Tradewinds.Schema.WarehouseInventory
  alias Tradewinds.Schema.Shipyard
  alias Tradewinds.Schema.Modification
end
