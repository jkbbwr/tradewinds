defmodule TradewindsWeb.WorldMapLive do
  use TradewindsWeb, :live_view

  alias Tradewinds.Fleet

  @impl true
  def mount(_params, _session, socket) do
    timer_ref =
      if connected?(socket) do
        {:ok, ref} = :timer.send_interval(15_000, self(), :tick)
        # Trigger an immediate update after connection
        send(self(), :tick)
        ref
      else
        nil
      end

    socket =
      socket
      |> assign(:page_title, "World Map")
      |> assign(:ships, get_ships_data())
      |> assign(:refresh_rate, "15")
      |> assign(:timer_ref, timer_ref)

    {:ok, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    ships = get_ships_data()
    {:noreply, socket |> assign(:ships, ships) |> push_event("update_ships", %{ships: ships})}
  end

  @impl true
  def handle_event("update_refresh_rate", %{"refresh_rate" => rate}, socket) do
    rate_int = String.to_integer(rate)

    if socket.assigns.timer_ref do
      :timer.cancel(socket.assigns.timer_ref)
    end

    {:ok, ref} = :timer.send_interval(rate_int * 1000, self(), :tick)

    {:noreply, assign(socket, refresh_rate: rate, timer_ref: ref)}
  end

  defp get_ships_data do
    transits =
      Fleet.list_active_transits()
      |> Tradewinds.Repo.preload(route: [:from, :to])

    now = DateTime.utc_now() |> DateTime.to_unix()

    Enum.map(transits, fn t ->
      departed_at = DateTime.to_unix(t.departed_at)
      arriving_at = DateTime.to_unix(t.ship.arriving_at)

      progress =
        if arriving_at <= departed_at do
          1.0
        else
          ratio = (now - departed_at) / (arriving_at - departed_at)
          max(0.0, min(1.0, ratio))
        end

      %{
        id: t.ship.id,
        name: t.ship.name,
        progress: progress,
        from: t.route.from.name,
        to: t.route.to.name
      }
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="landing-page" style="padding-top: 1rem; position: relative;">
      <header class="hero" style="margin-bottom: 2rem;">
        <div class="hero-content">
          <h1 class="title">Global Routes</h1>
          <p class="subtitle">Live Fleet Tracking</p>
        </div>
      </header>

      <div
        id="world-map"
        phx-hook="WorldMap"
        phx-update="ignore"
        data-routes={~p"/assets/routes.json"}
        data-initial-ships={Jason.encode!(@ships)}
        style="width: 100%; height: 600px; border-radius: 8px; border: 1px solid var(--card-border); box-shadow: 0 10px 30px rgba(0,0,0,0.5);"
      >
      </div>

      <div class="stats-section" style="margin-top: 2rem; display: flex; justify-content: space-between; align-items: center;">
        <a href="/" class="btn btn-secondary">Back to Dashboard</a>

        <form phx-change="update_refresh_rate" style="opacity: 0.1; transition: opacity 0.3s;" onmouseover="this.style.opacity=1" onmouseout="this.style.opacity=0.05">
          <select name="refresh_rate" style="background: transparent; color: inherit; border: 1px solid var(--card-border); padding: 4px; border-radius: 4px; cursor: pointer;">
            <%= for rate <- [1, 2, 5, 10, 15, 30, 60] do %>
              <option value={rate} selected={to_string(rate) == @refresh_rate} style="color: black;"><%= rate %>s</option>
            <% end %>
          </select>
        </form>
      </div>
    </div>
    """
  end
end
