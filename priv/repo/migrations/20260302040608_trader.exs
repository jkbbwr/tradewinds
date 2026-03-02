defmodule Tradewinds.Repo.Migrations.Trader do
  use Ecto.Migration

  def change do
    create table(:trader) do
      add :name, :text, null: false
      timestamps()
    end

    create table(:trader_position) do
      add :trader_id, references(:trader), null: false
      add :port_id, references(:port), null: false
      add :good_id, references(:good), null: false
      add :stock, :integer, null: false
      add :target_stock, :integer, null: false
      add :supply_rate, :float, null: false
      add :demand_rate, :float, null: false
      add :elasticity, :float, null: false
      add :spread, :float, null: false
      add :monthly_profit, :integer, null: false
      timestamps()
    end
  end
end
