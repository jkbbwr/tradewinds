defmodule Tradewinds.Repo.Migrations.Players do
  use Ecto.Migration

  def change do
    create table("player") do
      add :name, :text, null: false
      add :email, :text, null: false
      add :password_hash, :text, null: false
      add :enabled, :boolean, null: false, default: false
      timestamps()
    end

    create unique_index(:player, [:email])
  end
end
