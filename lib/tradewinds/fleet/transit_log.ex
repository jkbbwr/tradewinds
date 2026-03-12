defmodule Tradewinds.Fleet.TransitLog do
  use Tradewinds.Schema

  schema "transit_log" do
    field :departed_at, :utc_datetime_usec
    field :arrived_at, :utc_datetime_usec

    belongs_to :ship, Tradewinds.Fleet.Ship
    belongs_to :route, Tradewinds.World.Route
  end

  @doc """
  Builds a changeset for logging a transit.
  """
  def create_changeset(transit_log, attrs) do
    transit_log
    |> cast(attrs, [:ship_id, :route_id, :departed_at, :arrived_at])
    |> validate_required([:ship_id, :route_id, :departed_at])
    |> foreign_key_constraint(:ship_id)
    |> foreign_key_constraint(:route_id)
  end
end
