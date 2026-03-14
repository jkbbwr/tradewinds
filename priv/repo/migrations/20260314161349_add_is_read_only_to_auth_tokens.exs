defmodule Tradewinds.Repo.Migrations.AddIsReadOnlyToAuthTokens do
  use Ecto.Migration

  def change do
    alter table(:auth_token) do
      add :is_read_only, :boolean, default: false, null: false
    end
  end
end
