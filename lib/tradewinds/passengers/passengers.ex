defmodule Tradewinds.Passengers do
  @moduledoc """
  The Passengers context.
  Handles passenger generation, boarding, and delivery.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Passengers.Passenger
  alias Tradewinds.Passengers.PassengerLog
  alias Tradewinds.Fleet
  alias Tradewinds.World
  alias Tradewinds.Companies
  alias Tradewinds.Events

  require Logger

  @doc """
  Lists all passengers currently available at ports or boarded on ships.
  Supports pagination and filtering by port or ship.
  """
  def list_passengers(params \\ %{}) do
    opts =
      params
      |> Map.take([:after, :before, :limit])
      |> Map.to_list()
      |> Keyword.put_new(:limit, 50)
      |> Keyword.merge(cursor_fields: [inserted_at: :asc, id: :asc])

    query = Passenger
    query = if status = params[:status], do: where(query, status: ^status), else: query
    query = if port_id = params[:port_id], do: where(query, origin_port_id: ^port_id), else: query
    query = if ship_id = params[:ship_id], do: where(query, ship_id: ^ship_id), else: query

    Repo.paginate(query, opts)
  end

  @doc """
  Fetches a single passenger record.
  """
  def fetch_passenger(id) do
    Repo.get(Passenger, id) |> Repo.ok_or({:passenger_not_found, id})
  end

  def get_passenger!(id), do: Repo.get!(Passenger, id)

  @doc """
  Creates a new passenger request.
  """
  def create_passenger(
        origin_port_id,
        destination_port_id,
        count,
        bid,
        status,
        expires_at,
        ship_id \\ nil
      ) do
    %Passenger{}
    |> Passenger.changeset(%{
      origin_port_id: origin_port_id,
      destination_port_id: destination_port_id,
      count: count,
      bid: bid,
      status: status,
      expires_at: expires_at,
      ship_id: ship_id
    })
    |> Repo.insert()
    |> tap(fn
      {:ok, passenger} -> Events.broadcast_passenger_request_created(passenger)
      _ -> :ok
    end)
  end

  @doc """
  Deletes all passengers whose expires_at datetime is before the given datetime.
  """
  def sweep_expired_passengers(now \\ DateTime.utc_now()) do
    Passenger
    |> where([p], p.expires_at < ^now and p.status == :available)
    |> Repo.delete_all()
  end

  @doc """
  Boards a passenger group onto a ship if capacity and location requirements are met.
  """
  def board_passenger(%Tradewinds.Scope{company_id: company_id}, ship_id, passenger_id) do
    Repo.transact(fn ->
      with {:ok, ship} <- Fleet.fetch_ship(ship_id, preload: [:ship_type]),
           :ok <- validate_ship_ownership(ship, company_id),
           :ok <- validate_ship_docked(ship),
           {:ok, passenger} <- fetch_available_passenger(passenger_id),
           :ok <- validate_passenger_at_port(passenger, ship.port_id),
           :ok <- validate_passenger_capacity(ship, passenger) do
        passenger
        |> Passenger.changeset(%{status: :boarded, ship_id: ship.id})
        |> Repo.update()
      end
    end)
  end

  @doc """
  Disembarks all passengers on a ship whose destination matches the ship's current port.
  Credits the company for each successful delivery.
  """
  def disembark_passengers_for_ship(company_id, ship_id, port_id, now \\ DateTime.utc_now()) do
    passengers =
      Passenger
      |> where([p], p.ship_id == ^ship_id and p.destination_port_id == ^port_id and p.status == :boarded)
      |> Repo.all()

    Enum.reduce(passengers, {:ok, 0}, fn passenger, {:ok, total_payout} ->
      case process_passenger_delivery(company_id, passenger, now) do
        {:ok, payout} -> {:ok, total_payout + payout}
        error -> error
      end
    end)
  end

  defp process_passenger_delivery(company_id, passenger, now) do
    Repo.transact(fn ->
      with {:ok, _} <- Companies.record_transaction(company_id, passenger.bid, :passenger_fare, :passenger, passenger.id, now),
           {:ok, _} <- log_passenger_delivery(company_id, passenger, now),
           {:ok, _} <- Repo.delete(passenger) do
        {:ok, passenger.bid}
      end
    end)
  end

  defp log_passenger_delivery(company_id, passenger, now) do
    %PassengerLog{}
    |> PassengerLog.changeset(%{
      occurred_at: now,
      count: passenger.count,
      fare: passenger.bid,
      company_id: company_id,
      ship_id: passenger.ship_id,
      origin_port_id: passenger.origin_port_id,
      destination_port_id: passenger.destination_port_id
    })
    |> Repo.insert()
  end

  @doc """
  Spawns new passenger requests across various ports.
  Uses database-side randomness to select ports and routes efficiently.
  """
  def spawn_passengers do
    now = DateTime.utc_now()

    # Define some archetypes for "fun" variety
    archetypes = [
      %{name: "Standard Fare", count_range: 5..15, bid_multiplier: 1.0, weight: 70},
      %{name: "VIPs", count_range: 1..3, bid_multiplier: 4.5, weight: 10},
      %{name: "Large Group", count_range: 20..40, bid_multiplier: 0.8, weight: 20}
    ]

    # Use database-level randomness to pick approx 15% of ports and one random route for each
    World.list_random_port_routes()
    |> Enum.each(fn row ->
      archetype = weighted_random(archetypes)
      count = Enum.random(archetype.count_range)

      # Ensure it's profitable: Base rate of 10 per NM per passenger
      base_bid = row.distance * 10 * count
      final_bid = round(base_bid * archetype.bid_multiplier)

      # Random expiration between 30 and 90 minutes
      expires_at = DateTime.add(now, Enum.random(30..90) * 60, :second)

      create_passenger(row.origin_id, row.destination_id, count, final_bid, :available, expires_at)
    end)
  end

  defp weighted_random(items) do
    total_weight = Enum.reduce(items, 0, fn item, acc -> item.weight + acc end)
    pick = :rand.uniform(total_weight)
    find_weighted(items, pick, 0)
  end

  defp find_weighted([item | rest], pick, acc) do
    if pick <= acc + item.weight do
      item
    else
      find_weighted(rest, pick, acc + item.weight)
    end
  end

  defp validate_ship_ownership(ship, company_id) do
    if ship.company_id == company_id, do: :ok, else: {:error, :not_owner}
  end

  defp validate_ship_docked(ship) do
    if ship.status == :docked, do: :ok, else: {:error, :ship_not_docked}
  end

  defp fetch_available_passenger(passenger_id) do
    case Repo.get(Passenger, passenger_id) do
      nil -> {:error, :passenger_not_found}
      %{status: :available} = p -> {:ok, p}
      _ -> {:error, :passenger_not_available}
    end
  end

  defp validate_passenger_at_port(passenger, port_id) do
    if passenger.origin_port_id == port_id, do: :ok, else: {:error, :wrong_port}
  end

  defp validate_passenger_capacity(ship, passenger) do
    current_count =
      Passenger
      |> where([p], p.ship_id == ^ship.id and p.status == :boarded)
      |> Repo.aggregate(:sum, :count) || 0

    if current_count + passenger.count <= ship.ship_type.passengers do
      :ok
    else
      {:error, :capacity_exceeded}
    end
  end
end
