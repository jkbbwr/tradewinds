defmodule Tradewinds.Schema.Ship do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "ship" do
    field :name, :string
    field :state, Ecto.Enum, values: [:at_sea, :destroyed, :in_port]
    field :type, Ecto.Enum, values: [:cutter]
    field :capacity, :integer
    field :speed, :integer
    belongs_to :company, Tradewinds.Schema.Company, foreign_key: :company_id
    belongs_to :port, Tradewinds.Schema.Port, foreign_key: :port_id
    belongs_to :route, Tradewinds.Schema.Route, foreign_key: :route_id
    field :arriving_at, :utc_datetime

    timestamps()
  end

  @doc """
  Builds a changeset for the ship schema.
  """
  def changeset(ship, attrs) do
    ship
    |> cast(attrs, [:state, :type, :capacity, :speed, :company_id, :port_id, :route_id, :arriving_at])
    |> validate_required([:state, :type, :capacity, :speed, :company_id])
  end
end
