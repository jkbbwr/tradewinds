defmodule Tradewinds.World.Route do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Port

  schema "route" do
    belongs_to :from, Port, foreign_key: :from_id
    belongs_to :to, Port, foreign_key: :to_id
    field :distance, :integer

    timestamps()
  end

  @doc """
  Builds a changeset for the route schema.
  """
  def changeset(route, attrs) do
    route
    |> cast(attrs, [:from_id, :to_id, :distance])
    |> validate_required([:from_id, :to_id, :distance])
  end
end
