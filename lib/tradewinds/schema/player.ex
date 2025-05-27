defmodule Tradewinds.Schema.Player do
  use Tradewinds.Schema

  schema "player" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
    many_to_many :companies, Tradewinds.Schema.Company, join_through: Tradewinds.Schema.Officer
  end
end
