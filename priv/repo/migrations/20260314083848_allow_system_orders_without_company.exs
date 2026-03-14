defmodule Tradewinds.Repo.Migrations.AllowSystemOrdersWithoutCompany do
  use Ecto.Migration

  def change do
    alter table(:order_book) do
      add :trader_id, references(:trader, type: :uuid, on_delete: :delete_all)
      modify :company_id, :uuid, null: true, from: references(:company)
    end

    create index(:order_book, [:trader_id])

    create constraint(:order_book, :company_or_trader_id_present,
             check: "(company_id IS NOT NULL AND trader_id IS NULL) OR (company_id IS NULL AND trader_id IS NOT NULL)",
             comment: "An order must belong to either a company or a trader, but not both"
           )
  end
end
