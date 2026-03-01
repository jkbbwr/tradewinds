alias Tradewinds.Clock.Season
alias Tradewinds.Repo

# Active Season (Session)
now = DateTime.utc_now()
end_date = DateTime.add(now, 30, :day)

Repo.insert!(%Season{
  start_date: now,
  end_date: end_date,
  active: true,
  tick_duration_seconds: 24
})
