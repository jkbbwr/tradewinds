defmodule Tradewinds.Ships.Passenger do
  @moduledoc """
  Passenger schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Ships.Ship

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "passenger" do
    field :passenger_id, Ecto.UUID
    field :type, Ecto.Enum, values: [:company_agent]
    belongs_to :ship, Ship, foreign_key: :ship_id

    timestamps()
  end

  @doc """
  Changeset for creating a new passenger.
  """
  def create_changeset(passenger, attrs) do
    passenger
    |> cast(attrs, [:ship_id, :passenger_id, :type])
    |> validate_required([:passenger_id, :type])
  end
end
