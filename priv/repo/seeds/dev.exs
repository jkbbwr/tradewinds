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
