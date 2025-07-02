defmodule Tradewinds.Repo do
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  def ok_or(nil, error), do: {:error, {:not_found, error}}
  def ok_or(result, _error), do: {:ok, result}
end
