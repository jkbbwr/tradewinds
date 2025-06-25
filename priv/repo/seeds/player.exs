alias Tradewinds.Repo
alias Tradewinds.Schema.Player

Repo.insert!(%Player{
  name: "test",
  email: "test@example.com",
  password_hash:
    "$argon2id$v=19$m=65536,t=3,p=4$+iF5w94DXrxhG98uD/0H9Q$TM7oP4jfci+pcR/s8Of7Toyi3julPPcFfDH9PVbSwvY",
  enabled: true
})
