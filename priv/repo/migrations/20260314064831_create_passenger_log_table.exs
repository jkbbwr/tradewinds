defmodule Tradewinds.Repo.Migrations.CreatePassengerLogTable do
  use Ecto.Migration

  def change do
    create table(:passenger_log) do
      add :occurred_at, :utc_datetime_usec, null: false
      add :count, :integer, null: false
      add :fare, :integer, null: false
      add :company_id, references(:company), null: false
      add :ship_id, references(:ship), null: false
      add :origin_port_id, references(:port), null: false
      add :destination_port_id, references(:port), null: false

      timestamps(updated_at: false)
    end

    create index(:passenger_log, [:company_id, :occurred_at])
    create index(:passenger_log, [:ship_id, :occurred_at])
    create index(:passenger_log, [:origin_port_id])
    create index(:passenger_log, [:destination_port_id])
  end
end
