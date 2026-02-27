defmodule Tradewinds.Fleet do
  @moduledoc """
  The Fleet context.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Fleet.Ship
  alias Tradewinds.Fleet.ShipCargo
  alias Tradewinds.Scope
  alias Tradewinds.World

  def transit_ship(ship_id, route_id) do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- check_ship_docked(ship),
         {:ok, route} <- World.fetch_route_by_id(route_id),
         :ok <- check_ship_at_route_origin(ship, route),
         {:ok, ticks} <- transit_time(ship_id, route_id) do
      current_tick = Tradewinds.Clock.get_tick()

      ship
      |> Ship.transit_changeset(%{
        status: :traveling,
        port_id: nil,
        route_id: route.id,
        arriving_at: current_tick + ticks
      })
      |> Repo.update()
    end
  end

  defp check_ship_docked(ship) do
    if ship.status == :docked do
      :ok
    else
      {:error, :ship_not_docked}
    end
  end

  defp check_ship_at_route_origin(ship, route) do
    if ship.port_id == route.from_id do
      :ok
    else
      {:error, :wrong_port}
    end
  end

  def dock_ship(ship_id) do
    with {:ok, ship} <- fetch_ship(ship_id, preload: [:route]),
         :ok <- check_ship_traveling(ship),
         :ok <- check_ship_arrived(ship) do
      ship
      |> Ship.dock_changeset(ship.route.to_id)
      |> Repo.update()
    end
  end

  defp check_ship_traveling(ship) do
    if ship.status == :traveling do
      :ok
    else
      {:error, :ship_not_traveling}
    end
  end

  defp check_ship_arrived(ship) do
    current_tick = Tradewinds.Clock.get_tick()

    if ship.arriving_at && current_tick >= ship.arriving_at do
      :ok
    else
      {:error, :ship_not_arrived}
    end
  end

  @doc """
  Calculates the transit time in ticks for a specific ship on a specific route.
  """
  def transit_time(ship_id, route_id) do
    with {:ok, ship} <- fetch_ship(ship_id, preload: [:ship_type]),
         {:ok, route} <- World.fetch_route_by_id(route_id) do
      base_knots = ship.ship_type.speed
      distance_nm = route.distance
      bonus_bps = 0

      effective_knots =
        (base_knots * (10_000 + bonus_bps))
        |> div(10_000)
        |> max(1)

      ticks = div(distance_nm + effective_knots - 1, effective_knots)

      {:ok, ticks}
    end
  end

  def add_cargo(ship_id, good_id, quantity) do
    Repo.transact(fn ->
      with {:ok, ship} <- fetch_ship_for_update(ship_id),
           {:ok, current_total} <- current_cargo_total(ship_id),
           :ok <- check_capacity(ship, current_total, quantity) do
        %ShipCargo{}
        |> ShipCargo.create_changeset(%{ship_id: ship_id, good_id: good_id, quantity: quantity})
        |> Repo.insert(
          on_conflict: from(c in ShipCargo, update: [inc: [quantity: ^quantity]]),
          conflict_target: [:ship_id, :good_id]
        )
      end
    end)
  end

  defp fetch_ship_for_update(ship_id) do
    Ship
    |> where(id: ^ship_id)
    |> lock("FOR UPDATE")
    |> preload([:ship_type])
    |> Repo.one()
    |> Repo.ok_or(:ship_not_found)
  end

  defp check_capacity(ship, current_total, quantity) do
    if current_total + quantity > ship.ship_type.capacity do
      {:error, :capacity_exceeded}
    else
      :ok
    end
  end

  def remove_cargo(ship_id, good_id, quantity) when quantity > 0 do
    Repo.transact(fn ->
      with {:ok, cargo} <- fetch_ship_cargo_for_update(ship_id, good_id),
           :ok <- check_sufficient_cargo(cargo, quantity) do
        if cargo.quantity == quantity do
          Repo.delete(cargo)
        else
          cargo
          |> ShipCargo.update_quantity_changeset(%{quantity: cargo.quantity - quantity})
          |> Repo.update()
        end
      end
    end)
  end

  defp fetch_ship_cargo_for_update(ship_id, good_id) do
    ShipCargo
    |> where(ship_id: ^ship_id, good_id: ^good_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:cargo_not_found)
  end

  defp check_sufficient_cargo(cargo, quantity) do
    if cargo.quantity < quantity do
      {:error, :insufficient_cargo}
    else
      :ok
    end
  end

  @doc """
  Gets the total quantity of all cargo currently loaded on the given ship.
  """
  def current_cargo_total(ship_id) do
    query =
      from s in Ship,
        where: s.id == ^ship_id,
        left_join: c in ShipCargo,
        on: c.ship_id == s.id,
        group_by: s.id,
        select: {s.id, sum(c.quantity)}

    case Repo.one(query) do
      {_id, sum} -> {:ok, sum || 0}
      nil -> {:error, :ship_not_found}
    end
  end

  def fetch_ship(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Ship
    |> Repo.get(id)
    |> Repo.preload(preload)
    |> Repo.ok_or(:ship_not_found)
  end

  def rename_ship(%Scope{} = scope, ship_id, new_name) do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- Scope.authorizes?(scope, ship.company_id) do
      ship |> Ship.change_name_changeset(new_name) |> Repo.update()
    end
  end

  def assign_ship(ship_id, company_id) do
    case fetch_ship(ship_id) do
      {:ok, ship} -> Ship.transfer_changeset(ship, company_id) |> Repo.update()
      err -> err
    end
  end

  def transfer_ship(%Scope{} = scope, ship_id, new_company_id) do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- Scope.authorizes?(scope, ship.company_id) do
      ship |> Ship.transfer_changeset(new_company_id) |> Repo.update()
    end
  end

  def transfer_to_warehouse(ship_id, warehouse_id, good_id, quantity) when quantity > 0 do
    with {:ok, ship} <- fetch_ship(ship_id),
         {:ok, warehouse} <- Tradewinds.Logistics.fetch_warehouse(warehouse_id),
         :ok <- check_ship_at_warehouse(ship, warehouse) do
      Repo.transact(fn ->
        with {:ok, _} <- remove_cargo(ship_id, good_id, quantity),
             {:ok, _} <- Tradewinds.Logistics.add_cargo(warehouse_id, good_id, quantity) do
          {:ok, :transferred}
        end
      end)
    end
  end

  defp check_ship_at_warehouse(ship, warehouse) do
    cond do
      ship.status != :docked -> {:error, :ship_not_docked}
      ship.port_id == nil -> {:error, :ship_not_at_port}
      ship.port_id != warehouse.port_id -> {:error, :not_at_same_port}
      true -> :ok
    end
  end
end
