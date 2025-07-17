defmodule Tradewinds.Repo do
  @moduledoc """
  The application's Ecto repository.
  """
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  use EctoCursor

  @doc """
  Returns `{:ok, result}` if `result` is not nil, otherwise `{:error, error}`.
  """
  def ok_or(nil, error), do: {:error, error}
  def ok_or(result, _error), do: {:ok, result}

  @doc """
  Attempts to acquire an exclusive transaction-level advisory lock.
  """
  def try_advisory_xact_lock(key) do
    key = :erlang.phash2(key)

    case query("SELECT pg_try_advisory_xact_lock($1)", [key]) do
      {:ok, %{rows: [[lock_acquired]]}} -> {:ok, lock_acquired}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Sets the `statement_timeout` for the current transaction.
  """
  def set_statement_timeout(milliseconds) do
    query("SET statement_timeout = $1", [milliseconds])
  end
end
