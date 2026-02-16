defmodule Tradewinds.World.ShipType do
  use Tradewinds.Schema

  schema "ship_type" do
    field :name, :string
    field :description, :string
    field :capacity, :integer
    field :speed, :integer
    field :base_price, :integer
    field :upkeep, :integer

    timestamps()
  end

  @doc false
  def changeset(ship_type, attrs) do
    ship_type
    |> cast(attrs, [:name, :description, :capacity, :speed, :base_price, :upkeep])
    |> validate_required([:name, :description, :capacity, :speed, :base_price, :upkeep])
    |> validate_number(:capacity, greater_than: 0)
    |> validate_number(:speed, greater_than: 0)
    |> validate_number(:base_price, greater_than: 0)
    |> validate_number(:upkeep, greater_than: 0)
    |> unique_constraint(:name)
  end
end
