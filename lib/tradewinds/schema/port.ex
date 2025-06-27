defmodule Tradewinds.Schema.Port do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "port" do
    field :name, :string
    field :shortcode, :string
    field :warehouse_cost, :integer

    many_to_many :destinations, Tradewinds.Schema.Port,
      join_through: Tradewinds.Schema.Route,
      join_keys: [from_id: :id, to_id: :id]

    has_many :routes, Tradewinds.Schema.Route, foreign_key: :from_id

    belongs_to :country, Tradewinds.Schema.Country
    timestamps()
  end

  @doc """
  Builds a changeset for the port schema.
  """
  def changeset(port, attrs) do
    port
    |> cast(attrs, [:name, :shortcode, :country_id, :warehouse_cost])
    |> validate_required([:name, :shortcode, :country_id, :warehouse_cost])
    |> unique_constraint(:name)
    |> unique_constraint(:shortcode)
  end
end
