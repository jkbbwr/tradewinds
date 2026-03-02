defmodule Tradewinds.Repo.Migrations.Season do
  use Ecto.Migration

  def change do
    create table(:season) do
      add :start_date, :utc_datetime_usec, null: false
      add :end_date, :utc_datetime_usec, null: false
      add :active, :boolean, null: false, default: false
      add :tick_duration_seconds, :integer, null: false, default: 24

      timestamps()
    end

    create unique_index(:season, [:active],
             where: "active = true",
             name: :active_season_must_be_unique
           )
  end
end
