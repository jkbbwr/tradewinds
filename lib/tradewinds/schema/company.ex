defmodule Tradewinds.Schema.Company do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "company" do
    field :name, :string
    field :ticker, :string
    field :treasury, :integer
    belongs_to :home_port, Tradewinds.Schema.Port, foreign_key: :home_port_id

    many_to_many :directors, Tradewinds.Schema.Player, join_through: Tradewinds.Schema.Director

    timestamps()
  end

  @doc """
  Builds a changeset for creating a company.
  """
  def create_changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :ticker, :treasury, :home_port_id])
    |> put_assoc(:directors, attrs.directors)
    |> validate_required([:name, :ticker, :treasury, :home_port_id, :directors])
    |> validate_length(:directors, min: 1, message: "must have at least one director")
    |> validate_length(:ticker, max: 5)
    |> unique_constraint(:name)
    |> unique_constraint(:ticker)
    |> unique_constraint([:name, :ticker])
    |> foreign_key_constraint(:home_port_id)
  end
end
