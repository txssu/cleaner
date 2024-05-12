defmodule DelayBatcher.List do
  @moduledoc false
  use GenServer, restart: :transient

  alias DelayBatcher.ListsRegistry

  @spec start_link(GenServer.name()) :: GenServer.on_start()
  def start_link(arguments) do
    GenServer.start_link(__MODULE__, arguments)
  end

  @spec append(GenServer.server(), item) :: :ok when item: term()
  def append(list, item) do
    GenServer.call(list, {:append, item})
  end

  @impl GenServer
  def init(arguments) do
    id = Keyword.fetch!(arguments, :id)
    close_after = Keyword.fetch!(arguments, :close_after)
    perform_after = Keyword.fetch!(arguments, :perform_after)

    {module, function} = Keyword.fetch!(arguments, :action)

    items = Keyword.get(arguments, :items)

    ListsRegistry.register(id, module, function)

    Process.send_after(self(), {:close, id, module, function}, close_after)
    Process.send_after(self(), {:perform, id, module, function}, perform_after)

    {:ok, items}
  end

  @impl GenServer
  def handle_call({:append, item}, _from, items) do
    {:reply, :ok, [item | items]}
  end

  @impl GenServer
  def handle_info({:close, id, module, function}, items) do
    ListsRegistry.unregister(id, module, function)
    {:noreply, items}
  end

  @impl GenServer
  def handle_info({:perform, id, module, function}, items) do
    apply(module, function, [id, items])
    {:stop, :normal, []}
  end
end
