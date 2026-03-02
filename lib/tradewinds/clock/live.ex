defmodule Tradewinds.Clock.Live do
  @behaviour Tradewinds.Clock

  import Ecto.Query, warn: false
  alias Tradewinds.Repo
  alias Tradewinds.Clock.Season

  @cache_key {:tradewinds, :active_season}

  @impl true
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

  defp get_active_season() do
    :persistent_term.get(@cache_key, nil)
  end
end
