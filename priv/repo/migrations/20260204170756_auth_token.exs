defmodule Tradewinds.Repo.Migrations.AuthToken do
  use Ecto.Migration

  def change do
    create table(:auth_token) do
      add :token, :text, null: false
      add :player_id, references(:player, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:auth_token, [:token])
  end
end
