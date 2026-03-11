defmodule Tradewinds.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    discord_enabled = Application.get_env(:tradewinds, :discord)

    children =
      [
        Tradewinds.Repo,
        TradewindsWeb.Telemetry,
        {DNSCluster, query: Application.get_env(:tradewinds, :dns_cluster_query) || :ignore},
        {Oban, Application.fetch_env!(:tradewinds, Oban)},
        {Phoenix.PubSub, name: Tradewinds.PubSub},
        {Tradewinds.RateLimit, [clean_period: :timer.minutes(1)]},
        {Cachex, [:tradewinds_cache]},
        # Start to serve requests, typically the last entry
        TradewindsWeb.Endpoint
      ] ++ discord(discord_enabled)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tradewinds.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def discord(true) do
    bot_options = %{
      name: Tradewinds.Discord,
      consumer: Tradewinds.Discord.Consumer,
      intents: [:direct_messages, :guild_messages, :message_content],
      wrapped_token: fn -> System.fetch_env!("BOT_TOKEN") end
    }

    [
      {Nostrum.Bot, bot_options},
      {Nosedrum.Storage.Dispatcher, name: Nosedrum.Storage.Dispatcher}
    ]
  end

  def discord(false), do: []

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TradewindsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
