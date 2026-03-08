defmodule Tradewinds.Repo.Migrations.CreateBannedIp do
  use Ecto.Migration

  def change do
    create table(:banned_ip, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ip_address, :string, null: false
      add :reason, :string

      timestamps()
    end

    create unique_index(:banned_ip, [:ip_address])
  end
end
