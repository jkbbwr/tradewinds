defmodule Tradewinds.Repo.Migrations.Good do
  use Ecto.Migration

  def change do
    create table(:good) do
      add :name, :text, null: false
      add :description, :text, null: false
      add :category, :text, null: false
      add :base_price, :integer, null: false
      add :volatility, :float, null: false
      add :elasticity, :float, null: false

      timestamps()
    end

    create unique_index(:good, :name)

    create constraint(:good, "base_price_must_be_positive", check: "base_price > 0")

    create constraint(:good, "volatility_bounded",
             check: "volatility >= 0.0 and volatility <= 1.0"
           )

    create constraint(:good, "elasticity_bounded",
             check: "elasticity >= 0.0 and elasticity <= 1.0"
           )
  end
end
