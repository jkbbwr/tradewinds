defmodule Tradewinds.Repo.Migrations.UpdateMonthlyJobsToQuarterly do
  use Ecto.Migration

  def up do
    # Update pending and scheduled jobs to use the new worker
    execute("""
    UPDATE oban_jobs 
    SET worker = 'Tradewinds.Trade.TraderQuarterlyJob' 
    WHERE worker = 'Tradewinds.Trade.TraderMonthlyJob'
      AND state IN ('available', 'scheduled', 'retryable');
    """)
  end

  def down do
    # Revert to monthly jobs if needed
    execute("""
    UPDATE oban_jobs 
    SET worker = 'Tradewinds.Trade.TraderMonthlyJob' 
    WHERE worker = 'Tradewinds.Trade.TraderQuarterlyJob'
      AND state IN ('available', 'scheduled', 'retryable');
    """)
  end
end
