defmodule Tradewinds.Schema.Player do
  use Tradewinds.Schema

  schema "player" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :enabled, :boolean, default: false
    many_to_many :companies, Tradewinds.Schema.Company, join_through: Tradewinds.Schema.Officer
    timestamps()
  end
end
