defmodule Tradewinds.Fleet.Ship do
  use Tradewinds.Schema

  schema "ship" do
    field :name, :string
    field :status, Ecto.Enum, values: [:docked, :traveling]
    field :arriving_at, :utc_datetime_usec

    belongs_to :company, Tradewinds.Companies.Company
    belongs_to :ship_type, Tradewinds.World.ShipType
    belongs_to :port, Tradewinds.World.Port
    belongs_to :route, Tradewinds.World.Route

    timestamps()
  end

  @doc """
  Builds a changeset for initially creating a ship.
  Requires a specific location (either port or route).
  """
  def create_changeset(ship, attrs) do
    ship
    |> cast(attrs, [:name, :status, :arriving_at, :company_id, :ship_type_id, :port_id, :route_id])
    |> validate_required([:name, :status, :ship_type_id])
    |> validate_inclusion(:status, [:docked, :traveling])
    |> validate_location()
    |> check_constraint(:port_id, name: :port_xor_route)
  end

  @doc """
  Builds a changeset for renaming a ship.
  """
  def change_name_changeset(ship, new_name) do
    ship
    |> cast(%{name: new_name}, [:name])
    |> validate_required([:name])
    |> update_change(:name, &String.trim/1)
  end

  @doc """
  Builds a changeset for putting a ship into transit along a route.
  """
  def transit_changeset(ship, attrs) do
    ship
    |> cast(attrs, [:status, :arriving_at, :port_id, :route_id])
    |> validate_required([:status, :arriving_at, :route_id])
    |> validate_inclusion(:status, [:traveling])
    |> validate_location()
    |> check_constraint(:port_id, name: :port_xor_route)
  end

  @doc """
  Builds a changeset for docking a ship at a specific port.
  """
  def dock_changeset(ship, port_id) do
    ship
    |> cast(%{status: :docked, port_id: port_id, route_id: nil, arriving_at: nil}, [
      :status,
      :port_id,
      :route_id,
      :arriving_at
    ])
    |> validate_required([:status, :port_id])
    |> validate_inclusion(:status, [:docked])
    |> validate_location()
    |> check_constraint(:port_id, name: :port_xor_route)
  end

  @doc """
  Builds a changeset for transferring ownership of a ship to a different company.
  """
  def transfer_changeset(ship, new_company_id) do
    ship
    |> cast(%{company_id: new_company_id}, [:company_id])
    |> validate_required([:company_id])
    |> foreign_key_constraint(:company_id)
  end

  # Validates that a ship is exclusively at a port OR on a route, but never both or neither.
  defp validate_location(changeset) do
    port_id = get_field(changeset, :port_id)
    route_id = get_field(changeset, :route_id)

    cond do
      port_id && route_id ->
        add_error(changeset, :port_id, "cannot be set when route_id is present")

      is_nil(port_id) && is_nil(route_id) ->
        add_error(changeset, :port_id, "either port_id or route_id must be set")

      true ->
        changeset
    end
  end
end
