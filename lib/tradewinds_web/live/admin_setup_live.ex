defmodule TradewindsWeb.AdminSetupLive do
  use TradewindsWeb, :live_view

  alias Tradewinds.Jobs

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(5000, self(), :tick)

    {:ok, assign_stats(socket)}
  end

  def render(assigns) do
    ~H"""
    <h1>Tradewinds Admin Setup</h1>
    <div style="border: 1px solid #ddd; padding: 1.5rem; border-radius: 8px; margin-bottom: 2rem;">
        <h2>Background Jobs Kickstart</h2>
        
        <%= if @error do %>
          <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px; margin-bottom: 1rem;">
            <strong>Error!</strong> <%= @error %>
          </div>
        <% end %>

        <%= if @kickstarted do %>
          <div style="background: #d4edda; color: #155724; padding: 1rem; border-radius: 4px; margin-bottom: 1rem;">
            <strong>System Kickstarted!</strong> Background jobs are currently enqueued and running.
          </div>
          <p>NPC simulations, monthly upkeeps, and shipyard production are active.</p>
          <button disabled style="background: #ccc; color: #666; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: not-allowed;">
            Kickstart Jobs
          </button>
        <% else %>
          <p>The system is currently dormant. This will enqueue the first iteration of all recurring background jobs.</p>
          <button phx-click="kickstart" style="background: #007bff; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">
            Kickstart Jobs
          </button>
        <% end %>
    </div>

    <div style="border: 1px solid #ddd; padding: 1.5rem; border-radius: 8px;">
        <h2>Active Job Statistics</h2>
        <p>Current counts of pending/scheduled jobs in the system:</p>
        <ul style="list-style: none; padding: 0;">
            <%= if map_size(@job_counts) == 0 do %>
                <li><em>No active jobs found.</em></li>
            <% else %>
                <%= for {name, count} <- @job_counts do %>
                    <li style="padding: 0.5rem 0; border-bottom: 1px solid #eee;">
                        <strong><%= name %>:</strong> <%= count %>
                    </li>
                <% end %>
            <% end %>
        </ul>
    </div>
    """
  end

  def handle_event("kickstart", _params, socket) do
    require Logger
    Logger.info("Admin manually triggered system kickstart via LiveView")

    case Jobs.kickstart() do
      {:ok, _} ->
        {:noreply, assign_stats(socket) |> assign(:error, nil)}

      {:error, reason} ->
        Logger.error("Kickstart failed: #{inspect(reason)}")
        {:noreply, assign(socket, :error, "Failed to kickstart: #{inspect(reason)}")}
    end
  end

  def handle_info(:tick, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    assign(socket,
      kickstarted: Jobs.kickstarted?(),
      job_counts: Jobs.get_job_counts()
    )
    |> assign_new(:error, fn -> nil end)
  end
end
