# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tradewinds,
  gametime_anchor: ~U[1600-01-01 12:00:00Z],
  realtime_anchor: ~U[2025-07-15 00:00:00Z]

config :tradewinds,
  ecto_repos: [Tradewinds.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :tradewinds, Tradewinds.Repo, migration_primary_key: [type: :uuid]

# Configures the endpoint
config :tradewinds, TradewindsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TradewindsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Tradewinds.PubSub,
  live_view: [signing_salt: "y0Mxyx/Y"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tradewinds, Tradewinds.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
