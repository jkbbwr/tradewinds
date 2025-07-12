alias Tradewinds.Repo
alias Tradewinds.Schema.Player
alias Tradewinds.Schema.Company
alias Tradewinds.Schema.Port
alias Tradewinds.Schema.Warehouse

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
  port_id: lon.id,
  capacity: 1000,
  locked: false
})
