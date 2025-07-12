defmodule Tradewinds.Repo do
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  use EctoCursor

  def ok_or(nil, error), do: {:error, error}
  def ok_or(result, _error), do: {:ok, result}
end
