defmodule Tradewinds.Repo.Migrations.CompanyLedger do
  use Ecto.Migration

  def change do
    create table(:company_ledger) do
      add :company_id, references(:company), null: false
      add :occurred_at, :utc_datetime_usec, null: false
      add :amount, :integer, null: false
      add :reason, :text, null: false
      add :reference_type, :text, null: false
      add :reference_id, :uuid, null: false
      add :idempotency_key, :text, null: false
      add :meta, :jsonb, default: "{}"
      timestamps(updated_at: false)
    end

    create unique_index(:company_ledger, :idempotency_key)
    create constraint(:company_ledger, :amount_not_zero, check: "amount <> 0")
    create index(:company_ledger, [:company_id, desc: :occurred_at, desc: :inserted_at])
  end
end
