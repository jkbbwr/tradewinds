defmodule Tradewinds.Economy do
  @moduledoc """
  The Economy context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Economy.TradeLog
  alias Tradewinds.Economy.Shock

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
  Creates a new economy shock.
  """
  def create_shock(attrs) do
    %Shock{}
    |> Shock.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns aggregated modifiers for a specific port/good at a specific time.
  Multiplies all active modifiers together.
  """
  def get_active_modifiers(port_id, good_id, now) do
    query =
      from s in Shock,
        where: s.status == :active,
        where: s.start_time <= ^now,
        where: is_nil(s.end_time) or s.end_time >= ^now,
        where: is_nil(s.port_id) or s.port_id == ^port_id,
        where: is_nil(s.good_id) or s.good_id == ^good_id

    Repo.all(query)
    |> Enum.reduce(
      %{demand: 1.0, supply: 1.0, price: 1.0, volatility: 1.0},
      fn shock, acc ->
        %{
          demand: acc.demand * (shock.demand_modifier / 10_000),
          supply: acc.supply * (shock.supply_modifier / 10_000),
          price: acc.price * (shock.price_modifier / 10_000),
          volatility: acc.volatility * (shock.volatility_modifier / 10_000)
        }
      end
    )
  end

  @doc """
  Calculates the net player flow from the NPC trader for a specific port, good, and time range.
  Positive value means players bought from the NPC.
  Negative value means players sold to the NPC.
  """
  def net_player_flow_from_npc(port_id, good_id, start_time, end_time) do
    query =
      from t in TradeLog,
        where: t.port_id == ^port_id and t.good_id == ^good_id,
        where: t.occurred_at >= ^start_time and t.occurred_at <= ^end_time,
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
  Calculates the Volume Weighted Average Price (VWAP) for a port/good over a time range.
  """
  def vwap(port_id, good_id, start_time, end_time) do
    query =
      from t in TradeLog,
        where: t.port_id == ^port_id and t.good_id == ^good_id,
        where: t.occurred_at >= ^start_time and t.occurred_at <= ^end_time,
        select: {sum(t.price * t.quantity), sum(t.quantity)}

    case Repo.one(query) do
      {nil, _} -> nil
      {_, 0} -> nil
      {total_value, total_qty} -> total_value / total_qty
    end
  end
end
