defmodule Tradewinds.Repo.Migrations.Company do
  use Ecto.Migration

  def change do
    create table(:company) do
      add :name, :text, null: false
      add :ticker, :string, size: 5, null: false
      add :treasury, :integer, null: false
      timestamps()
    end

    create unique_index(:company, [:name])
    create unique_index(:company, [:ticker])
    create unique_index(:company, [:name, :ticker])

    create table(:director) do
      add :company_id, references(:company, on_delete: :delete_all), null: false
      add :player_id, references(:player, on_delete: :delete_all), null: false
    end

    create unique_index(:director, [:company_id, :player_id])
  end
end
