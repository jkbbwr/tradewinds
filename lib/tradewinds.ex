defmodule Tradewinds do
  @moduledoc """
  Tradewinds keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if comes from the database, an external API or others.
  """

  import Ecto.Query, warn: false
  alias Tradewinds.Repo

  @doc """
  Emits system-wide telemetry stats (infrastructure concern).
  """
  def emit_system_stats do
    :telemetry.execute([:tradewinds, :system, :stats], %{
      oban_lag_seconds: get_oban_lag()
    })
  end

  @doc """
  Calculates the current Oban job lag in seconds.
  """
  def get_oban_lag do
    now = DateTime.utc_now()

    query =
      from(j in "oban_jobs",
        where: j.state in ["available", "retryable"],
        select: min(j.scheduled_at)
      )

    case Repo.one(query) do
      nil ->
        0

      min_scheduled ->
        diff = DateTime.diff(now, min_scheduled, :second)
        max(0, diff)
    end
  end

  @doc """
  Checks if the database is responding to queries.
  """
  def db_active? do
    case Repo.query("SELECT 1") do
      {:ok, _} -> true
      _ -> false
    end
  end
end
