defmodule Tradewinds.Repo.Migrations.CreateArbitrageLog do
  use Ecto.Migration

  def change do
    create table(:arbitrage_log) do
      add :good_id, references(:good), null: false
      add :cheap_port_id, references(:port), null: false
      add :expensive_port_id, references(:port), null: false
      add :margin, :float, null: false
      add :action, :string, null: false
      add :details, :map, null: false

      timestamps()
    end

    create index(:arbitrage_log, [:good_id])
    create index(:arbitrage_log, [:cheap_port_id])
    create index(:arbitrage_log, [:expensive_port_id])
  end
end
