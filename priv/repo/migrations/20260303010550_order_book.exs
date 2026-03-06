defmodule Tradewinds.Repo.Migrations.OrderBook do
  use Ecto.Migration

  def change do
    create table(:order_book) do
      add :company_id, references(:company), null: false
      add :port_id, references(:port), null: false
      add :good_id, references(:good), null: false
      add :side, :text, null: false
      add :price, :integer, null: false, comment: "limit price"
      add :total, :integer, null: false
      add :remaining, :integer, null: false
      add :created_at, :utc_datetime_usec, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :posted_reputation, :integer, null: false
      add :status, :text, null: false
      timestamps()
    end

    create index(:order_book, [:port_id, :good_id, :status, :side, :price, :inserted_at])
    create index(:order_book, [:status, :expires_at])
    create index(:order_book, [:company_id, :status])
    create index(:order_book, [:port_id])
    create index(:order_book, [:good_id])
  end
end
