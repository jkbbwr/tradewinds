defmodule Tradewinds.Schema.Modification do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "modification" do
    belongs_to :ship, Tradewinds.Schema.Ship, foreign_key: :ship_id

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
