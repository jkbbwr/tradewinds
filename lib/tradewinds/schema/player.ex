defmodule Tradewinds.Schema.Player do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "player" do
    field :name, :string
    field :email, :string
    field :password_hash, :string

    timestamps()
    many_to_many :companies, Tradewinds.Schema.Company, join_through: Tradewinds.Schema.Officer
  end

  @doc """
  Builds a changeset for the player schema.
  """
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :email, :password_hash])
    |> validate_required([:name, :email, :password_hash])
    |> unique_constraint(:email)
  end
end
