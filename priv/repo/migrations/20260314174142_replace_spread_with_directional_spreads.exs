defmodule Tradewinds.Repo.Migrations.ReplaceSpreadWithDirectionalSpreads do
  use Ecto.Migration

  def up do
    alter table(:trader_position) do
      add :ask_spread, :float
      add :bid_spread, :float
    end

    # Backfill new fields with existing spread
    execute("UPDATE trader_position SET ask_spread = spread, bid_spread = spread")

    # Now make them required
    alter table(:trader_position) do
      modify :ask_spread, :float, null: false
      modify :bid_spread, :float, null: false
      remove :spread
    end
  end

  def down do
    alter table(:trader_position) do
      add :spread, :float
    end

    execute("UPDATE trader_position SET spread = ask_spread")

    alter table(:trader_position) do
      modify :spread, :float, null: false
      remove :ask_spread
      remove :bid_spread
    end
  end
end
