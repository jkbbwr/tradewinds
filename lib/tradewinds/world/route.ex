defmodule Tradewinds.World.Route do
  use Tradewinds.Schema

  schema "route" do
    field :distance, :integer

    belongs_to :from, Tradewinds.World.Port
    belongs_to :to, Tradewinds.World.Port
  end

  @doc false
  def create_changeset(route, attrs) do
    route
    |> cast(attrs, [:distance, :from_id, :to_id])
    |> validate_required([:distance, :from_id, :to_id])
    |> unique_constraint([:from_id, :to_id], name: :route_from_id_to_id_index)
    |> unique_constraint([:to_id, :from_id], name: :route_to_id_from_id_index)
  end
end
