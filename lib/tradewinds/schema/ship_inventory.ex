defmodule Tradewinds.Schema.ShipInventory do
  use Tradewinds.Schema
  import Ecto.Changeset

  schema "ship_inventory" do
    belongs_to :item, Tradewinds.Schema.Item, foreign_key: :item_id
    belongs_to :ship, Tradewinds.Schema.Ship, foreign_key: :ship_id
    field :amount, :integer

    timestamps()
  end

  @doc """
  Builds a changeset for the ship_inventory schema.
  """
  def changeset(ship_inventory, attrs) do
    ship_inventory
    |> cast(attrs, [:item_id, :ship_id, :amount])
    |> validate_required([:item_id, :ship_id, :amount])
  end
end