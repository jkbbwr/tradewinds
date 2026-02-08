defmodule Tradewinds.Companies.Company do
  use Tradewinds.Schema

  schema "company" do
    field :name, :string
    field :ticker, :string
    field :treasury, :integer

    has_many :directors, Tradewinds.Companies.Director
    many_to_many :players, Tradewinds.Accounts.Player, join_through: Tradewinds.Companies.Director

    timestamps()
  end

  def create_changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :ticker, :treasury])
    |> validate_required([:name, :ticker, :treasury])
    |> validate_length(:ticker, max: 5)
    |> unique_constraint(:name)
    |> unique_constraint(:ticker)
  end
end
