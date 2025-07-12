defmodule Tradewinds.Ships.Ship do
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
    belongs_to :company, Company, foreign_key: :company_id
    belongs_to :port, Port, foreign_key: :port_id
    belongs_to :route, Route, foreign_key: :route_id
    has_many :inventory, ShipInventory, foreign_key: :ship_id
    field :arriving_at, :utc_datetime

    timestamps()
  end

  def create_changeset(ship, attrs) do
    ship
    |> cast(attrs, [
      :name,
      :state,
      :type,
      :capacity,
      :speed,
      :company_id,
      :port_id,
      :route_id,
      :arriving_at
    ])
    |> validate_required([:name, :state, :type, :capacity, :speed])
  end

  def update_company_changeset(ship, attrs) do
    ship
    |> cast(attrs, [:company_id])
    |> validate_required([:company_id])
  end

  def transit_changeset(ship, route, arriving_at) do
    ship
    |> cast(%{state: :at_sea, route_id: route.id, arriving_at: arriving_at}, [
      :state,
      :route_id,
      :arriving_at
    ])
    |> validate_required([:state, :route_id, :arriving_at])
  end
end
