defmodule Tradewinds.Repo.Migrations.CompanyReputation do
  use Ecto.Migration

  def change do
    alter table(:company) do
      add :reputation, :integer, null: false, default: 1000
    end
  end
end
