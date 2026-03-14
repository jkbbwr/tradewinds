defmodule Tradewinds.Passengers.PassengerLog do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "passenger_log" do
    field :occurred_at, :utc_datetime_usec
    field :count, :integer
    field :fare, :integer

    belongs_to :company, Tradewinds.Companies.Company
    belongs_to :ship, Tradewinds.Fleet.Ship
    belongs_to :origin_port, Tradewinds.World.Port
    belongs_to :destination_port, Tradewinds.World.Port

    timestamps(updated_at: false)
  end

  def changeset(log, attrs) do
    log
    |> cast(attrs, [
      :occurred_at,
      :count,
      :fare,
      :company_id,
      :ship_id,
      :origin_port_id,
      :destination_port_id
    ])
    |> validate_required([
      :occurred_at,
      :count,
      :fare,
      :company_id,
      :ship_id,
      :origin_port_id,
      :destination_port_id
    ])
  end
end
