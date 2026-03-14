defmodule Tradewinds.Repo.Migrations.ScaleDownPortTaxes do
  use Ecto.Migration

  def up do
    execute("UPDATE port SET tax_rate_bps = ROUND(tax_rate_bps * 0.8)")
  end

  def down do
    execute("UPDATE port SET tax_rate_bps = ROUND(tax_rate_bps / 0.8)")
  end
end
