defmodule Tradewinds.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc """
  Starts the application and its supervision tree.
  """
  @impl true
  def start(_type, _args) do
    children =
      [
        TradewindsWeb.Telemetry,
        Tradewinds.Repo,
        {DNSCluster, query: Application.get_env(:tradewinds, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Tradewinds.PubSub},
        # Start a worker by calling: Tradewinds.Worker.start_link(arg)
        # {Tradewinds.Worker, arg},
        # Start to serve requests, typically the last entry
        TradewindsWeb.Endpoint,
        {Highlander, {Tradewinds.Ships.TransitManager, []}},
        {Highlander, {Tradewinds.World.TaxManager, []}},
        {Highlander, {Tradewinds.Shipyard.ShipyardManager, []}}
      ] ++ game_loop()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tradewinds.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Handles application configuration changes.
  """
  @impl true
  def config_change(changed, _new, removed) do
    TradewindsWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp game_loop() do
    if Application.get_env(:tradewinds, :game_loop_enabled) do
      realtime_anchor = Application.fetch_env!(:tradewinds, :realtime_anchor)
      gametime_anchor = Application.fetch_env!(:tradewinds, :gametime_anchor)
      opts = [realtime_anchor: realtime_anchor, gametime_anchor: gametime_anchor]

      [
        {Highlander, {Tradewinds.GameLoop, opts}}
      ]
    else
      []
    end
  end
end
