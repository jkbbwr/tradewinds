defmodule Tradewinds.Repo do
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres
end
