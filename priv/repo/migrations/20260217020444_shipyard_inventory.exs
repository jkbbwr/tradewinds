defmodule Tradewinds.Repo.Migrations.ShipyardInventory do
  use Ecto.Migration

  def change do
    create table(:shipyard_inventory) do
      add :shipyard_id, references(:shipyard), null: false
      add :ship_type_id, references(:ship_type), null: false
      add :ship_id, references(:ship), null: false
      add :cost, :integer, null: false
      timestamps()
    end

    create index(:shipyard_inventory, [:shipyard_id, :shipyard_type_id])
  end
end
