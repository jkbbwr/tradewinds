defmodule Tradewinds.World.Item do
  @moduledoc """
  Item schema.
  """
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "item" do
    field :name, :string
    field :shortcode, :string
    field :description, :string

    timestamps()
  end

  @doc """
  Builds a changeset for the item schema.
  """
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :shortcode, :description])
    |> validate_required([:name, :shortcode, :description])
    |> unique_constraint(:shortcode)
  end
end
