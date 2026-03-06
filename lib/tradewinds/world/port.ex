defmodule Tradewinds.World.Port do
  use Tradewinds.Schema

  schema "port" do
    field :name, :string
    field :shortcode, :string
    field :is_hub, :boolean, default: false
    field :tax_rate_bps, :integer, default: 0

    belongs_to :country, Tradewinds.World.Country

    has_one :shipyard, Tradewinds.Shipyards.Shipyard

    timestamps()
  end

  @doc """
  Builds a changeset for creating a static port location in the world.
  """
  def create_changeset(port, attrs) do
    port
    |> cast(attrs, [:name, :shortcode, :country_id, :is_hub, :tax_rate_bps])
    |> validate_required([:name, :shortcode, :country_id])
    |> validate_number(:tax_rate_bps, greater_than_or_equal_to: 0)
    |> unique_constraint(:name)
    |> unique_constraint(:shortcode)
  end
end
