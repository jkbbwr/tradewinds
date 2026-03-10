defmodule Tradewinds.Repo.Migrations.CreateEconomyShocks do
  use Ecto.Migration

  def change do
    create table(:economy_shocks) do
      add :name, :text, null: false
      add :description, :text
      add :status, :text, null: false, default: "pending"
      add :port_id, references(:port)
      add :good_id, references(:good)
      add :start_time, :utc_datetime_usec, null: false
      add :end_time, :utc_datetime_usec
      add :demand_modifier, :integer, null: false, default: 10000
      add :supply_modifier, :integer, null: false, default: 10000
      add :price_modifier, :integer, null: false, default: 10000
      add :volatility_modifier, :integer, null: false, default: 10000
      timestamps()
    end

    create index(:economy_shocks, [:status, :start_time, :end_time])
    create index(:economy_shocks, [:port_id])
    create index(:economy_shocks, [:good_id])
  end
end
