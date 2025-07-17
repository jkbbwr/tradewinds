defmodule Tradewinds.Ships.Ship do
  @moduledoc """
  Ship schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Companies.Company
  alias Tradewinds.World.Port
  alias Tradewinds.World.Route
  alias Tradewinds.Ships.ShipInventory

  schema "ship" do
    field :name, :string
    field :state, Ecto.Enum, values: [:at_sea, :destroyed, :in_port]
    field :type, Ecto.Enum, values: [:cutter]
    field :capacity, :integer
    field :speed, :integer
    field :max_passengers, :integer
    belongs_to :company, Company, foreign_key: :company_id
    belongs_to :port, Port, foreign_key: :port_id
    belongs_to :route, Route, foreign_key: :route_id
    has_many :inventory, ShipInventory, foreign_key: :ship_id
    field :arriving_at, :utc_datetime

    timestamps()
  end

  @doc """
  Changeset for creating a new ship.
  """
  def create_changeset(ship, attrs) do
    ship
    |> cast(attrs, [
      :name,
      :state,
      :type,
      :capacity,
      :speed,
      :company_id,
      :max_passengers,
      :port_id,
      :route_id,
      :arriving_at
    ])
    |> validate_required([:name, :state, :max_passengers, :type, :capacity, :speed])
  end

  @doc """
  Changeset for updating a ship's company.
  """
  def update_company_changeset(ship, attrs) do
    ship
    |> cast(attrs, [:company_id])
    |> validate_required([:company_id])
  end

  @doc """
  Changeset for putting a ship in transit.
  """
  def transit_changeset(ship, route, arriving_at) do
    ship
    |> cast(
      %{state: :at_sea, port_id: nil, route_id: route.id, arriving_at: arriving_at},
      [:state, :port_id, :route_id, :arriving_at]
    )
    |> validate_required([:state, :route_id, :arriving_at])
  end

  @doc """
  Changeset for a ship's arrival at a port.
  """
  def arrival_changeset(ship, destination_port_id) do
    ship
    |> cast(
      %{
        state: :in_port,
        port_id: destination_port_id,
        route_id: nil,
        arriving_at: nil
      },
      [:state, :port_id, :route_id, :arriving_at]
    )
    |> validate_required([:state, :port_id])
  end
end
