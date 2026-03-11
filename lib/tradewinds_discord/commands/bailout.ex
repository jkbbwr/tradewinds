defmodule Tradewinds.Discord.Commands.Bailout do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Bailout a company"
  end

  @impl true
  def command(_interaction) do
    [
      content: "Not ready yet"
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
