defmodule Tradewinds.TradingRepo do
  alias Tradewinds.Repo
  alias Tradewinds.Schema.TraderInventory
  alias Tradewinds.Schema.TraderPlan
  alias Tradewinds.Schema.Ship
  alias Tradewinds.Schema.Warehouse
  alias Tradewinds.Schema.ShipInventory
  alias Tradewinds.Schema.WarehouseInventory
  import Ecto.Query

  def fetch_trader_inventory(trader_id, item_id) do
    Repo.fetch_by(TraderInventory, trader_id: trader_id, item_id: item_id)
  end

  def fetch_trader_plan(trader_id, item_id) do
    Repo.fetch_by(TraderPlan, trader_id: trader_id, item_id: item_id)
  end

  def get_stock_in_port(company_id, port_id, item_id) do
    ship_inventory =
      from(s in Ship,
        join: si in ShipInventory,
        on: s.id == si.ship_id,
        where: s.company_id == ^company_id and s.port_id == ^port_id and si.item_id == ^item_id,
        select: %{type: "ship", id: si.id, amount: si.amount}
      )

    warehouse_inventory =
      from(w in Warehouse,
        join: wi in WarehouseInventory,
        on: w.id == wi.warehouse_id,
        where: w.company_id == ^company_id and w.port_id == ^port_id and wi.item_id == ^item_id,
        select: %{type: "warehouse", id: wi.id, amount: wi.amount}
      )

    query =
      from(u in subquery(ship_inventory),
        union_all: ^subquery(warehouse_inventory)
      )

    Repo.all(query)
  end
end
