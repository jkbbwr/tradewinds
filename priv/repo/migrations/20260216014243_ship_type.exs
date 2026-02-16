defmodule Tradewinds.Repo.Migrations.ShipType do
  use Ecto.Migration

  def change do
    create table(:ship_type) do
      add :name, :text, null: false
      add :description, :text, null: false
      add :capacity, :integer, null: false
      add :speed, :integer, null: false
      add :base_price, :integer, null: false
      add :upkeep, :integer, null: false

      timestamps()
    end

    create unique_index(:ship_type, :name)
    create constraint(:ship_type, :capacity_pos_integer, check: "capacity > 0")
    create constraint(:ship_type, :speed_pos_integer, check: "speed > 0")
    create constraint(:ship_type, :base_price_pos_integer, check: "base_price > 0")
    create constraint(:ship_type, :upkeep_pos_integer, check: "upkeep > 0")
  end
end
