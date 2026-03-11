defmodule Tradewinds.Discord.Commands.Health do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Check server health"
  end

  @impl true
  def command(_interaction) do
    lag = Tradewinds.get_oban_lag()
    db_active = Tradewinds.db_active?()

    [
      content: "oban_lag=#{lag}, db_active=#{db_active}. Looks good to me..."
    ]
  end

  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    []
  end
end
