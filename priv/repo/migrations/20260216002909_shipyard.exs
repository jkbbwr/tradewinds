defmodule Tradewinds.Repo.Migrations.Shipyard do
  use Ecto.Migration

  def change do
    create table(:shipyard) do
      add :port_id, references(:port), null: false
      timestamps()
    end

    create unique_index(:shipyard, :port_id)
  end
end
