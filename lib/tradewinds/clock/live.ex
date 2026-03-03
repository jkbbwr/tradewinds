defmodule Tradewinds.Clock.Live do
  @moduledoc """
  The live clock adapter.
  Calculates the current tick based on the active season's start date and tick duration.
  Utilizes `:persistent_term` for extremely fast, concurrent cache reads.
  """
  @behaviour Tradewinds.Clock

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Clock.Season

  @cache_key {:tradewinds, :active_season}

  @impl true
  @doc """
  Calculates elapsed ticks by taking the time difference between now and the season start,
  divided by the configured tick duration in seconds.
  """
  def get_tick() do
    case get_active_season() do
      %{start_date: start_date, tick_duration_seconds: duration} ->
        diff = DateTime.diff(DateTime.utc_now(), start_date, :second)
        max(0, div(diff, duration))

      nil ->
        0
    end
  end

  @impl true
  @doc """
  Queries the database for the active season and stores its parameters in `:persistent_term`.
  """
  def refresh_cache() do
    season = Repo.one(from s in Season, where: s.active == true, limit: 1)

    cache_data =
      if season do
        %{
          id: season.id,
          start_date: season.start_date,
          tick_duration_seconds: season.tick_duration_seconds
        }
      else
        nil
      end

    :persistent_term.put(@cache_key, cache_data)
    :ok
  end

  # Retrieves the cached active season map.
  defp get_active_season() do
    :persistent_term.get(@cache_key, nil)
  end
end
