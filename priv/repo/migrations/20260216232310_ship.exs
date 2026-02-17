defmodule Tradewinds.Repo.Migrations.Ship do
  use Ecto.Migration

  def change do
    create table(:ship) do
      add :name, :text, null: false
      add :company_id, references(:company)
      add :ship_type_id, references(:ship_type), null: false
      add :status, :text, null: false
      add :port_id, references(:port)
      add :route_id, references(:route)
      add :arriving_at, :integer
      timestamps()
    end

    create index(:ship, [:company_id])
    create index(:ship, [:ship_type_id])
    create index(:ship, [:port_id], where: "port_id IS NOT NULL")
    create index(:ship, [:route_id], where: "route_id IS NOT NULL")
    create index(:ship, [:status, :arriving_at])
    create unique_index(:ship, [:name, :company_id])

    create constraint(:ship, "port_xor_route",
             check:
               "((port_id IS NOT NULL and route_id IS NULL) OR (port_id IS NULL and route_id IS NOT NULL))",
             comment: "a ship is either at sea or in a port. it cannot be both"
           )
  end
end
