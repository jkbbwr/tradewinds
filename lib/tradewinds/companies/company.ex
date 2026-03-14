defmodule Tradewinds.Companies.Company do
  use Tradewinds.Schema

  schema "company" do
    field :name, :string
    field :ticker, :string
    field :treasury, :integer
    field :reputation, :integer, default: 1000
    field :status, Ecto.Enum, values: [:active, :bankrupt], default: :active

    belongs_to :home_port, Tradewinds.World.Port
    has_many :directors, Tradewinds.Companies.Director
    many_to_many :players, Tradewinds.Accounts.Player, join_through: Tradewinds.Companies.Director

    timestamps()
  end

  @doc """
  Builds a changeset for initializing a new company.
  """
  def create_changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :ticker, :treasury, :reputation, :home_port_id, :status])
    |> validate_required([:name, :ticker, :treasury, :home_port_id])
    |> update_change(:ticker, &String.upcase/1)
    |> validate_length(:ticker, max: 5)
    |> validate_number(:reputation, greater_than: 0)
    |> unique_constraint(:name)
    |> unique_constraint(:ticker)
    |> foreign_key_constraint(:home_port_id)
  end

  @doc """
  Builds a changeset for updating the company status.
  """
  def update_status_changeset(company, status) do
    company
    |> cast(%{status: status}, [:status])
    |> validate_required([:status])
  end

  @doc """
  Builds a changeset for mutating the treasury balance, ensuring it never drops below zero.
  """
  def update_treasury_changeset(company, delta) do
    company
    |> change()
    |> put_change(:treasury, company.treasury + delta)
    |> validate_number(:treasury, greater_than_or_equal_to: 0)
  end

  @doc """
  Builds a changeset for mutating the reputation, ensuring it stays strictly positive.
  """
  def update_reputation_changeset(company, delta) do
    company
    |> change()
    |> put_change(:reputation, company.reputation + delta)
    |> validate_number(:reputation, greater_than: 0)
  end
end
