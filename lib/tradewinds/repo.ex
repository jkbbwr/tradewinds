defmodule Tradewinds.Repo do
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  @spec fetch(Ecto.Queryable.t(), binary(), keyword()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch(queryable, id, opts \\ []) do
    case get(queryable, id, opts) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  @spec fetch_by(Ecto.Queryable.t(), keyword() | map(), keyword()) ::
          {:ok, Ecto.Schema.t()} | {:error, :not_found}
  def fetch_by(queryable, clauses, opts \\ []) do
    case get_by(queryable, clauses, opts) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  @doc """
  A small wrapper around `Repo.transaction/2'.

  Commits the transaction if the lambda returns `:ok` or `{:ok, result}`,
  rolling it back if the lambda returns `:error` or `{:error, reason}`. In both
  cases, the function returns the result of the lambda.
  """
  @spec transact((-> any()), keyword()) :: {:ok, any()} | {:error, any()}
  def transact(fun, opts \\ []) do
    transaction(
      fn ->
        case fun.() do
          {:ok, value} -> value
          :ok -> :transaction_commited
          {:error, reason} -> rollback(reason)
          :error -> rollback(:transaction_rollback_error)
        end
      end,
      opts
    )
  end
end
