defmodule Tradewinds.Repo.Migrations.CreatePassengerTable do
  use Ecto.Migration

  def change do
    create table(:passenger) do
      add :ship_id, references(:ship)
      add :count, :integer, null: false
      add :bid, :integer, null: false
      add :status, :string, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :origin_port_id, references(:port), null: false
      add :destination_port_id, references(:port), null: false
      timestamps()
    end
  end
end
