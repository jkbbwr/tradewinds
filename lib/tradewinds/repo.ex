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

  def fetch_one(queryable, opts \\ []) do
    case one(queryable, opts) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
