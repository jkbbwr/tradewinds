defmodule Tradewinds.Discord.WorldEventsSubscriber do
  use GenServer

  @channel_id 1_481_666_526_837_735_465
  @name {:global, __MODULE__}

  def start_link(_arg) do
    case GenServer.start_link(__MODULE__, :ok, name: @name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _pid}} -> :ignore
      error -> error
    end
  end

  @impl true
  def init(:ok) do
    # Subscribe during initialization
    Phoenix.PubSub.subscribe(Tradewinds.PubSub, "events:world:all")
    {:ok, %{}}
  end

  @impl true
  def handle_info({:message, payload}, state) do
    message =
      payload
      |> Jason.encode!(pretty: true)
      |> Tradewinds.Discord.Safe.escape_unescaped_backticks()

    Nostrum.Api.Message.create(
      @channel_id,
      "```json\n#{message}```"
    )

    {:noreply, state}
  end
end
