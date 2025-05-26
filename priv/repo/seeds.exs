alias Tradewinds.Repo
alias Tradewinds.Schema.Season

Repo.insert!(%Season{
  password: "polly wants a password",
  start_date: DateTime.utc_now() |> DateTime.truncate(:second)
})

Code.eval_file("europe.exs", "priv/repo/seeds")
