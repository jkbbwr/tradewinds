defmodule Tradewinds.Counter do
  use GenServer, restart: :transient

  ## Client API

  @doc """
  Starts the counter GenServer.
  """
  def start([value]) do
    GenServer.start(__MODULE__, value, name: {:global, Counter})
  end

  @doc """
  Increments the counter by the given amount (defaults to 1).
  """
  def inc(server, amount \\ 1) when is_integer(amount) and amount >= 0 do
    GenServer.call(server, {:inc, amount})
  end

  @doc """
  Decrements the counter by the given amount (defaults to 1).
  """
  def dec(server, amount \\ 1) when is_integer(amount) and amount >= 0 do
    GenServer.call(server, {:dec, amount})
  end

  @doc """
  Gets the current value of the counter.
  """
  def get(server) do
    GenServer.call(server, :get)
  end

  ## Server Callbacks

  @impl true
  def init(initial_value) when is_integer(initial_value) do
    {:ok, initial_value}
  end

  @impl true
  def handle_call({:inc, amount}, _from, state) do
    new_state = state + amount
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:dec, amount}, _from, state) do
    new_state = state - amount
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
