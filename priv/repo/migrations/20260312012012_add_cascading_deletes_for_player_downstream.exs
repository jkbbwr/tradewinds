defmodule Tradewinds.Repo.Migrations.AddCascadingDeletesForPlayerDownstream do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE ship DROP CONSTRAINT ship_company_id_fkey"
    alter table(:ship) do
      modify :company_id, references(:company, on_delete: :delete_all)
    end

    execute "ALTER TABLE company_ledger DROP CONSTRAINT company_ledger_company_id_fkey"
    alter table(:company_ledger) do
      modify :company_id, references(:company, on_delete: :delete_all)
    end

    execute "ALTER TABLE order_book DROP CONSTRAINT order_book_company_id_fkey"
    alter table(:order_book) do
      modify :company_id, references(:company, on_delete: :delete_all)
    end

    execute "ALTER TABLE transit_log DROP CONSTRAINT transit_log_ship_id_fkey"
    alter table(:transit_log) do
      modify :ship_id, references(:ship, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE ship DROP CONSTRAINT ship_company_id_fkey"
    alter table(:ship) do
      modify :company_id, references(:company, on_delete: :nothing)
    end

    execute "ALTER TABLE company_ledger DROP CONSTRAINT company_ledger_company_id_fkey"
    alter table(:company_ledger) do
      modify :company_id, references(:company, on_delete: :nothing)
    end

    execute "ALTER TABLE order_book DROP CONSTRAINT order_book_company_id_fkey"
    alter table(:order_book) do
      modify :company_id, references(:company, on_delete: :nothing)
    end

    execute "ALTER TABLE transit_log DROP CONSTRAINT transit_log_ship_id_fkey"
    alter table(:transit_log) do
      modify :ship_id, references(:ship, on_delete: :nothing)
    end
  end
end
