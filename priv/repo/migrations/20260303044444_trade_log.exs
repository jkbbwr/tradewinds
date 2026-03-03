defmodule Tradewinds.Repo.Migrations.TradeLog do
  use Ecto.Migration

  def change do
    create table(:trade_log) do
      add :tick, :integer, null: false
      add :quantity, :integer, null: false
      add :price, :integer, null: false
      add :source, :text, null: false
      add :port_id, references(:port), null: false
      add :good_id, references(:good), null: false
      add :buyer_id, :uuid
      add :seller_id, :uuid
      timestamps(updated_at: false)
    end

    create index(:trade_log, [:port_id, :good_id, :tick])
    create index(:trade_log, [:buyer_id, :tick])
    create index(:trade_log, [:seller_id, :tick])
    # create index(:trade_log, [:seller_id, :tick])
  end
end
