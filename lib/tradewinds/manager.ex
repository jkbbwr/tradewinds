defmodule Tradewinds.Manager do
  use GenServer

  def start_link(spec) do
    GenServer.start_link(__MODULE__, spec, name: __MODULE__)
  end

  def init(spec) do
    {:ok, restart_or_monitor(spec)}
  end

  @doc false
  def handle_info({:DOWN, _, :process, _, :normal}, spec) do
    # In case the process is stopped normally with `stop/0`
    {:stop, :normal, spec}
  end

  def handle_info({:DOWN, _, :process, _, _reason}, spec) do
    # Try to either restart the global GenServer or monitor the newly
    # created one.
    Process.sleep(:rand.uniform(1800) + 200)
    {:noreply, restart_or_monitor(spec)}
  end

  defp restart_or_monitor({module, args} = spec) do
    case module.start(args) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
    |> Process.monitor()

    spec
  end
end
