defmodule Tradewinds.Manager do
  @moduledoc """
  A generic manager that handles subscribing to the game tick.
  """

  @doc "Callback for custom initialization."
  @callback handle_init(opts :: any()) :: {:ok, state :: any()}

  @doc "Callback to handle a game tick."
  @callback handle_tick(tick :: integer(), gametime :: DateTime.t(), state :: any()) ::
              {:noreply, any()} | {:stop, any(), any()}

  defmacro __using__(_opts) do
    quote do
      use GenServer, restart: :permanent
      @behaviour Tradewinds.Manager

      require Logger
      alias Phoenix.PubSub

      @pubsub Tradewinds.PubSub
      @tick_topic "tick"

      # Default implementation that can be overridden.
      def start_link(opts) do
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)
      end

      @impl true
      def init(opts) do
        Logger.info("#{__MODULE__} starting...")
        PubSub.subscribe(@pubsub, @tick_topic)
        handle_init(opts)
      end

      def handle_init(opts) do
        {:ok, %{}}
      end

      @impl true
      def handle_info({:tick, tick, gametime}, state) do
        handle_tick(tick, gametime, state)
      end

      @impl true
      def terminate(reason, state) do
        Logger.info("#{__MODULE__} terminating. Reason: #{inspect(reason)}")
        :ok
      end

      defoverridable start_link: 1, init: 1, handle_info: 2, terminate: 2
    end
  end
end
