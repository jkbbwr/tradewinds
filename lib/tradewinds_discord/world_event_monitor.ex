defmodule Tradewinds.Discord.WorldEventsSubscriber do
  @channel_id 1_481_666_526_837_735_465
  use Task

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    Phoenix.PubSub.subscribe(Tradewinds.PubSub, "events:world:all")
    loop()
  end

  defp loop do
    receive do
      {:message, payload} ->
        Nostrum.Api.Message.create(
          @channel_id,
          "```json\n#{Jason.encode!(payload, pretty: true)}```"
        )

        loop()
    end
  end
end
