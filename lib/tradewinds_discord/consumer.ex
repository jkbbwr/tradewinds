defmodule Tradewinds.Discord.Consumer do
  @behaviour Nostrum.Consumer

  alias Nostrum.Api.Message

  def handle_event({:READY, _data, _ws_state}) do
    commands = [
      {"toggle", Tradewinds.Discord.Commands.Toggle},
      {"health", Tradewinds.Discord.Commands.Health}
    ]

    for {name, command} <- commands do
      Nosedrum.Storage.Dispatcher.queue_command(name, command)
    end

    Nosedrum.Storage.Dispatcher.process_queue(1_479_655_489_376_878_602)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Nosedrum.Storage.Dispatcher.handle_interaction(interaction)
  end

  # Ignore any other events
  def handle_event(_), do: :ok
end
