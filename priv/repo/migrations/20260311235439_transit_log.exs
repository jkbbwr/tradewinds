defmodule Tradewinds.Repo.Migrations.TransitLog do
  use Ecto.Migration

  def change do
    create table(:transit_log) do
      add :ship_id, references(:ship), null: false
      add :route_id, references(:route), null: false
      add :departed_at, :utc_datetime_usec, null: false
      add :arrived_at, :utc_datetime_usec
    end

    create index(:transit_log, [:ship_id])
    create index(:transit_log, [:route_id])
    create index(:transit_log, [:departed_at])
  end
end
