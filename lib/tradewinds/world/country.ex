defmodule Tradewinds.World.Country do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "country" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc """
  Builds a changeset for the country schema.
  """
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  def create_changeset(country, attrs) do
    country
    |> changeset(attrs)
    |> put_change(:description, attrs[:description] || "no description")
  end
end
