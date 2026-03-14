defmodule Tradewinds.Passengers.Passenger do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "passenger" do
    field :count, :integer
    field :bid, :integer
    field :status, Ecto.Enum, values: [:available, :boarded]
    field :expires_at, :utc_datetime_usec

    belongs_to :ship, Tradewinds.Fleet.Ship
    belongs_to :origin_port, Tradewinds.World.Port
    belongs_to :destination_port, Tradewinds.World.Port

    timestamps()
  end

  def changeset(passenger, attrs) do
    passenger
    |> cast(attrs, [:count, :bid, :status, :expires_at, :ship_id, :origin_port_id, :destination_port_id])
    |> validate_required([:count, :bid, :status, :expires_at, :origin_port_id, :destination_port_id])
    |> validate_inclusion(:status, [:available, :boarded])
  end
end
