defmodule Tradewinds.Repo do
  use Ecto.Repo,
    otp_app: :tradewinds,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Returns `{:ok, result}` if `result` is not nil, otherwise `{:error, error}`.
  """
  def ok_or(nil, error), do: {:error, error}
  def ok_or(result, _error), do: {:ok, result}
end
