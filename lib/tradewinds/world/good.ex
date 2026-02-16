defmodule Tradewinds.World.Good do
  use Tradewinds.Schema

  schema "good" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :base_price, :integer
    field :volatility, :float
    field :elasticity, :float

    timestamps()
  end

  @doc false
  def changeset(good, attrs) do
    good
    |> cast(attrs, [:name, :description, :category, :base_price, :volatility, :elasticity])
    |> validate_required([:name, :description, :category, :base_price, :volatility, :elasticity])
    |> validate_number(:base_price, greater_than: 0)
    |> validate_number(:volatility, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> validate_number(:elasticity, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
  end
end
