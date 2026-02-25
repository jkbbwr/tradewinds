defmodule Tradewinds.Fleet.ShipCargo do
  use Tradewinds.Schema

  schema "ship_cargo" do
    belongs_to :ship, Tradewinds.Fleet.Ship
    belongs_to :good, Tradewinds.World.Good
    field :quantity, :integer

    timestamps()
  end

  @doc false
  def create_changeset(ship_cargo, attrs) do
    ship_cargo
    |> cast(attrs, [:quantity, :ship_id, :good_id])
    |> validate_required([:quantity, :ship_id, :good_id])
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:ship_id)
    |> foreign_key_constraint(:good_id)
    |> unique_constraint([:ship_id, :good_id], name: :ship_cargo_ship_id_good_id_index)
    |> check_constraint(:quantity, name: :quantity_must_be_positive)
  end

  @doc false
  def update_quantity_changeset(ship_cargo, attrs) do
    ship_cargo
    |> cast(attrs, [:quantity])
    |> validate_required([:quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> check_constraint(:quantity, name: :quantity_must_be_positive)
  end
end
