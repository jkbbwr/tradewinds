defmodule Tradewinds.Companies.Company do
  use Tradewinds.Schema
  import Ecto.Changeset

  alias Tradewinds.World.Port
  alias Tradewinds.Accounts.Player
  alias Tradewinds.Companies.Director
  alias Tradewinds.Companies.Office

  schema "company" do
    field :name, :string
    field :ticker, :string
    field :treasury, :integer
    belongs_to :home_port, Port, foreign_key: :home_port_id

    many_to_many :directors, Player, join_through: Director
    has_many :office, Office

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
    |> validate_length(:ticker, max: 5)
    |> unique_constraint(:name)
    |> unique_constraint(:ticker)
    |> unique_constraint([:name, :ticker])
    |> foreign_key_constraint(:home_port_id)
  end

  def treasury_changeset(company, new_treasury) do
    company
    |> cast(%{treasury: new_treasury}, [:treasury])
    |> validate_required([:treasury])
    |> validate_number(:treasury, greater_than_or_equal_to: 0)
  end
end
