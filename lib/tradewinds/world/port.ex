defmodule Tradewinds.World.Port do
  use Tradewinds.Schema

  schema "port" do
    field :name, :string
    field :shortcode, :string

    belongs_to :country, Tradewinds.World.Country

    has_one :shipyard, Tradewinds.Shipyards.Shipyard

    timestamps()
  end

  @doc false
  def create_changeset(port, attrs) do
    port
    |> cast(attrs, [:name, :shortcode, :country_id])
    |> validate_required([:name, :shortcode, :country_id])
    |> unique_constraint(:name)
    |> unique_constraint(:shortcode)
  end
end
