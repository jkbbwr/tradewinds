defmodule Tradewinds.Repo.Migrations.Route do
  use Ecto.Migration

  def change do
    create table(:route) do
      add :from_id, references(:port, on_delete: :delete_all), null: false
      add :to_id, references(:port, on_delete: :delete_all), null: false
      add :distance, :integer
    end

    create unique_index(:route, [:from_id, :to_id])
    create unique_index(:route, [:to_id, :from_id])
  end
end
