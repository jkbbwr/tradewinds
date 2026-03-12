defmodule Tradewinds.World.Port do
  use Tradewinds.Schema

  schema "port" do
    field :name, :string
    field :shortcode, :string
    field :is_hub, :boolean, default: false
    field :tax_rate_bps, :integer, default: 0

    belongs_to :country, Tradewinds.World.Country
    has_one :shipyard, Tradewinds.Shipyards.Shipyard

    has_many :trader_positions, Tradewinds.Trade.TraderPosition
    has_many :traders, through: [:trader_positions, :trader]

    has_many :outgoing_routes, Tradewinds.World.Route, foreign_key: :from_id
    has_many :destinations, through: [:outgoing_routes, :to]

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
