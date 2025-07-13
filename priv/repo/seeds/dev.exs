alias Tradewinds.Repo
alias Tradewinds.Accounts.Player
alias Tradewinds.Companies.Company
alias Tradewinds.World.Port
alias Tradewinds.Warehouses.Warehouse
alias Tradewinds.Trading.Trader
alias Tradewinds.Trading.TraderInventory
alias Tradewinds.Trading.TraderPlan
alias Tradewinds.World.Item

kibb =
  Repo.insert!(%Player{
    name: "kibb",
    email: "kibb@kibb.dev",
    password_hash:
      "$argon2id$v=19$m=65536,t=3,p=4$+iF5w94DXrxhG98uD/0H9Q$TM7oP4jfci+pcR/s8Of7Toyi3julPPcFfDH9PVbSwvY",
    enabled: true
  })

lon = Repo.get_by!(Port, name: "London")

eic =
  Repo.insert!(%Company{
    name: "East India Company",
    ticker: "EIC",
    treasury: 1_000_000,
    home_port_id: lon.id,
    directors: [kibb]
  })

Repo.insert!(%Warehouse{
  company_id: eic.id,
  port_id: lon.id
})

london_trader =
  Repo.insert!(%Trader{
    name: "London Trader",
    port_id: lon.id
  })

items_to_stock = ["Beer", "Cloth", "Coal", "Fish", "Timber"]

for item_name <- items_to_stock do
  item = Repo.get_by!(Item, name: item_name)

  Repo.insert!(%TraderInventory{
    trader_id: london_trader.id,
    item_id: item.id,
    stock: 100
  })

  Repo.insert!(%TraderPlan{
    trader_id: london_trader.id,
    item_id: item.id,
    average_acquisition_cost: 100,
    ideal_stock_level: 150,
    target_profit_margin: 1.2,
    max_buy_sell_spread: 0.5,
    price_elasticity: 0.3,
    liquidity_factor: 0.1,
    consumption_rate: 10,
    reversion_rate: 0.05,
    regional_cost: 100
  })
end
