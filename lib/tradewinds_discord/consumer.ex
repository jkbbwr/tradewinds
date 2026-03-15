defmodule Tradewinds.Discord.Consumer do
  @behaviour Nostrum.Consumer

  def handle_event({:READY, _data, _ws_state}) do
    commands = [
      {"toggle", Tradewinds.Discord.Commands.Toggle},
      {"health", Tradewinds.Discord.Commands.Health},
      {"bailout", Tradewinds.Discord.Commands.Bailout},
      {"grant", Tradewinds.Discord.Commands.Grant}
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
