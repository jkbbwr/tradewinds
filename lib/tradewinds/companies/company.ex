defmodule Tradewinds.Companies.Company do
  use Tradewinds.Schema

  schema "company" do
    field :name, :string
    field :ticker, :string
    field :treasury, :integer

    belongs_to :home_port, Tradewinds.World.Port
    has_many :directors, Tradewinds.Companies.Director
    many_to_many :players, Tradewinds.Accounts.Player, join_through: Tradewinds.Companies.Director

    timestamps()
  end

  def create_changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :ticker, :treasury, :home_port_id])
    |> validate_required([:name, :ticker, :treasury, :home_port_id])
    |> validate_length(:ticker, max: 5)
    |> unique_constraint(:name)
    |> unique_constraint(:ticker)
    |> foreign_key_constraint(:home_port_id)
  end

  def update_treasury_changeset(company, delta) do
    company
    |> change()
    |> put_change(:treasury, company.treasury + delta)
    |> validate_number(:treasury, greater_than_or_equal_to: 0)
  end
end
