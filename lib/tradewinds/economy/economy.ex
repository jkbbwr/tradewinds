defmodule Tradewinds.Economy do
  @moduledoc """
  The Economy context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Economy.TradeLog

  @system_npc_id "00000000-0000-0000-0000-000000000000"

  def system_npc_id, do: @system_npc_id

  @doc """
  Logs a trade execution.
  """
  def log_trade(attrs) do
    %TradeLog{}
    |> TradeLog.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Calculates the net player flow from the NPC trader for a specific port, good, and tick range.
  Positive value means players bought from the NPC.
  Negative value means players sold to the NPC.
  """
  def net_player_flow_from_npc(port_id, good_id, start_tick, end_tick) do
    query =
      from t in TradeLog,
        where: t.port_id == ^port_id and t.good_id == ^good_id,
        where: t.tick >= ^start_tick and t.tick <= ^end_tick,
        where: t.source == :npc_trader

    Repo.all(query)
    |> Enum.reduce(0, fn t, acc ->
      cond do
        t.seller_id == @system_npc_id -> acc + t.quantity # Player bought from NPC
        t.buyer_id == @system_npc_id -> acc - t.quantity # Player sold to NPC
        true -> acc
      end
    end)
  end

  @doc """
  Calculates the Volume Weighted Average Price (VWAP) for a port/good over a tick range.
  """
  def vwap(port_id, good_id, start_tick, end_tick) do
    query =
      from t in TradeLog,
        where: t.port_id == ^port_id and t.good_id == ^good_id,
        where: t.tick >= ^start_tick and t.tick <= ^end_tick,
        select: {sum(t.price * t.quantity), sum(t.quantity)}

    case Repo.one(query) do
      {nil, _} -> nil
      {_, 0} -> nil
      {total_value, total_qty} -> total_value / total_qty
    end
  end
end
