defmodule Tradewinds.Repo.Migrations.RenameTraderMonthlyProfitToQuarterly do
  use Ecto.Migration

  def change do
    rename table(:trader_position), :monthly_profit, to: :quarterly_profit
  end
end
