defmodule Tradewinds.Repo.Migrations.CreatePorts do
  use Ecto.Migration

  def change do
    create table(:country) do
      add :name, :text, null: false
      add :description, :text, null: false
      timestamps()
    end

    create table(:port) do
      add :name, :text, null: false
      add :shortcode, :text, null: false
      add :country_id, references(:country), null: false
      timestamps()
    end

    create unique_index(:port, :name)
    create unique_index(:port, :shortcode)
  end
end
