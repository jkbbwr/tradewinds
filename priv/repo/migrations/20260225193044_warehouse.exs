defmodule Tradewinds.Repo.Migrations.Warehouse do
  use Ecto.Migration

  def change do
    create table(:warehouse) do
      add :port_id, references(:port, on_delete: :delete_all), null: false
      add :company_id, references(:company, on_delete: :delete_all), null: false
      add :level, :integer, null: false
      add :capacity, :integer, null: false
      timestamps()
    end

    create unique_index(:warehouse, [:port_id, :company_id])
    create constraint(:warehouse, :level_must_be_positive, check: "level > 0")
    create constraint(:warehouse, :capacity_must_be_positive, check: "capacity > 0")
  end
end
