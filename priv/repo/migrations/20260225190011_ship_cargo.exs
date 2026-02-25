defmodule Tradewinds.Repo.Migrations.ShipCargo do
  use Ecto.Migration

  def change do
    create table(:ship_cargo) do
      add :ship_id, references(:ship, on_delete: :delete_all), null: false
      add :good_id, references(:good, on_delete: :delete_all), null: false
      add :quantity, :integer, null: false
      timestamps()
    end

    create unique_index(:ship_cargo, [:ship_id, :good_id])
    create constraint(:ship_cargo, :quantity_must_be_positive, check: "quantity > 0")
  end
end
