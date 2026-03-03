defmodule Tradewinds.Repo do
  @moduledoc """
  The application repository, managing the underlying PostgreSQL database connection.
  """

  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  @doc """
  A utility helper that converts a `nil` result into an `{:error, error}` tuple,
  or wraps a valid result in an `{:ok, result}` tuple.
  Often used at the end of Ecto queries.
  """
  def ok_or(nil, error), do: {:error, error}
  def ok_or(result, _error), do: {:ok, result}
end
