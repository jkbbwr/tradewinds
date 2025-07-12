defmodule Tradewinds.Ships.Modification do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.Ships.Ship

  schema "modification" do
    belongs_to :ship, Ship, foreign_key: :ship_id

    timestamps()
  end

  @doc """
  Builds a changeset for the modification schema.
  """
  def changeset(modification, attrs) do
    modification
    |> cast(attrs, [:ship_id])
    |> validate_required([:ship_id])
  end
end
