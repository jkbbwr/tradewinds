defmodule Tradewinds.Repo do
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  use EctoCursor

  def ok_or(nil, error), do: {:error, error}
  def ok_or(result, _error), do: {:ok, result}

  def try_advisory_xact_lock(key) do
    key = :erlang.phash2(key)

    case query("SELECT pg_try_advisory_xact_lock($1)", [key]) do
      {:ok, %{rows: [[lock_acquired]]}} -> {:ok, lock_acquired}
      {:error, reason} -> {:error, reason}
    end
  end

  def set_statement_timeout(milliseconds) do
    query("SET statement_timeout = $1", [milliseconds])
  end
end
