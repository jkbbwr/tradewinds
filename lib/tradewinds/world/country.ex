defmodule Tradewinds.World.Country do
  use Tradewinds.Schema

  schema "country" do
    field :name, :string
    field :description, :string

    has_many :ports, Tradewinds.World.Port

    timestamps()
  end

  @doc false
  def create_changeset(country, attrs) do
    country
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
