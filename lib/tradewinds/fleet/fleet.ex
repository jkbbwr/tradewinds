defmodule Tradewinds.Fleet do
  @moduledoc """
  The Fleet context.
  Handles ship operations including transit, cargo management, and ownership.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Fleet.Ship
  alias Tradewinds.Fleet.ShipCargo
  alias Tradewinds.Scope
  alias Tradewinds.World
  alias Tradewinds.Companies

  @doc """
  Initiates travel for a docked ship along a specific route.
  Sets the ship's status to `:traveling` and calculates the arrival time.
  """
  def transit_ship(%Scope{} = scope, ship_id, route_id) do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- Scope.authorizes?(scope, ship.company_id),
         :ok <- check_ship_docked(ship),
         {:ok, route} <- World.fetch_route_by_id(route_id),
         :ok <- check_ship_at_route_origin(ship, route),
         {:ok, seconds} <- transit_time(ship_id, route_id) do
      now = DateTime.utc_now()
      arrival_time = DateTime.add(now, seconds, :second)

      Repo.transact(fn ->
        with {:ok, updated_ship} <-
               ship
               |> Ship.transit_changeset(%{
                 status: :traveling,
                 port_id: nil,
                 route_id: route.id,
                 arriving_at: arrival_time
               })
               |> Repo.update(),
             {:ok, _job} <-
               %{"ship_id" => ship_id}
               |> Tradewinds.Fleet.TransitJob.new(schedule_in: seconds)
               |> Oban.insert() do
          {:ok, updated_ship}
        end
      end)
    end
  end

  def process_upkeep(company_id, now) do
    Repo.transact(fn ->
      cost = calculate_total_upkeep(company_id)

      if cost > 0 do
        Companies.record_transaction(company_id, -cost, :ship_upkeep, :ship, company_id, now)
      else
        {:ok, 0}
      end
    end)
  end

  # Validates that a ship is currently docked at a port.
  defp check_ship_docked(ship) do
    if ship.status == :docked do
      :ok
    else
      {:error, :ship_not_docked}
    end
  end

  # Validates that a ship is at the origin port of the given route.
  defp check_ship_at_route_origin(ship, route) do
    if ship.port_id == route.from_id do
      :ok
    else
      {:error, :wrong_port}
    end
  end

  @doc """
  Docks a traveling ship at its destination port if the arrival time has passed.
  """
  def dock_ship(ship_id) do
    with {:ok, ship} <- fetch_ship(ship_id, preload: [:route]),
         :ok <- check_ship_traveling(ship),
         :ok <- check_ship_arrived(ship) do
      ship
      |> Ship.dock_changeset(ship.route.to_id)
      |> Repo.update()
    end
  end

  # Validates that a ship is currently traveling on a route.
  defp check_ship_traveling(ship) do
    if ship.status == :traveling do
      :ok
    else
      {:error, :ship_not_traveling}
    end
  end

  # Checks if the current time is past the ship's arrival time.
  defp check_ship_arrived(ship) do
    now = DateTime.utc_now()

    if ship.arriving_at && DateTime.compare(now, ship.arriving_at) != :lt do
      :ok
    else
      {:error, :ship_not_arrived}
    end
  end

  @doc """
  Calculates the transit time in real-time seconds for a specific ship on a specific route,
  taking into account the ship's speed and route distance.
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

      game_hours = div(distance_nm + effective_knots - 1, effective_knots)
      seconds = game_hours * 24

      {:ok, seconds}
    end
  end

  @doc """
  Adds a quantity of a specific good to a ship's cargo, enforcing capacity limits.
  """
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

  # Fetches and locks a ship record for transaction safety.
  defp fetch_ship_for_update(ship_id) do
    Ship
    |> where(id: ^ship_id)
    |> lock("FOR UPDATE")
    |> preload([:ship_type])
    |> Repo.one()
    |> Repo.ok_or(:ship_not_found)
  end

  # Ensures the ship has enough remaining capacity for the new cargo.
  defp check_capacity(ship, current_total, quantity) do
    if current_total + quantity > ship.ship_type.capacity do
      {:error, :capacity_exceeded}
    else
      :ok
    end
  end

  @doc """
  Removes a quantity of a specific good from a ship's cargo.
  Deletes the cargo record entirely if the quantity drops to zero.
  """
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

  # Fetches and locks a specific cargo record for transaction safety.
  defp fetch_ship_cargo_for_update(ship_id, good_id) do
    ShipCargo
    |> where(ship_id: ^ship_id, good_id: ^good_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
    |> Repo.ok_or(:cargo_not_found)
  end

  # Ensures the ship actually holds enough of the requested good.
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

  @doc """
  Calculates the total monthly upkeep cost for all ships owned by a company.
  """
  def calculate_total_upkeep(company_id) do
    query =
      from s in Ship,
        where: s.company_id == ^company_id,
        join: st in assoc(s, :ship_type),
        select: sum(st.upkeep)

    Repo.one(query) || 0
  end

  @doc """
  Fetches a single ship by ID, optionally preloading associations.
  """
  def fetch_ship(id, opts \\ []) do
    preload = Keyword.get(opts, :preload, [])

    Ship
    |> Repo.get(id)
    |> Repo.preload(preload)
    |> Repo.ok_or(:ship_not_found)
  end

  @doc """
  Renames a ship, enforcing scope authorization to ensure the caller owns the company.
  """
  def rename_ship(%Scope{} = scope, ship_id, new_name) do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- Scope.authorizes?(scope, ship.company_id) do
      ship |> Ship.change_name_changeset(new_name) |> Repo.update()
    end
  end

  @doc """
  Assigns a ship to a new company (used by the system, no scope authorization).
  """
  def assign_ship(ship_id, company_id) do
    case fetch_ship(ship_id) do
      {:ok, ship} -> Ship.transfer_changeset(ship, company_id) |> Repo.update()
      err -> err
    end
  end

  @doc """
  Transfers a ship to another company, enforcing scope authorization on the current owner.
  """
  def transfer_ship(%Scope{} = scope, ship_id, new_company_id) do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- Scope.authorizes?(scope, ship.company_id) do
      ship |> Ship.transfer_changeset(new_company_id) |> Repo.update()
    end
  end

  @doc """
  Atomically transfers cargo from a docked ship to a warehouse at the same port.
  """
  def transfer_to_warehouse(%Scope{} = scope, ship_id, warehouse_id, good_id, quantity) when quantity > 0 do
    with {:ok, ship} <- fetch_ship(ship_id),
         :ok <- Scope.authorizes?(scope, ship.company_id),
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

  # Validates that a ship is docked at the same port as the target warehouse.
  defp check_ship_at_warehouse(ship, warehouse) do
    cond do
      ship.status != :docked -> {:error, :ship_not_docked}
      ship.port_id == nil -> {:error, :ship_not_at_port}
      ship.port_id != warehouse.port_id -> {:error, :not_at_same_port}
      true -> :ok
    end
  end

  @doc """
  Emits telemetry stats for the Fleet context.
  """
  def emit_stats do
    stats = %{
      total_ships: Repo.aggregate(Ship, :count, :id),
      ships_at_sea: Repo.aggregate(from(s in Ship, where: s.status == :traveling), :count, :id)
    }

    :telemetry.execute([:tradewinds, :fleet, :stats], stats)
  end
end
