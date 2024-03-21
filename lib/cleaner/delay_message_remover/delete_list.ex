defmodule Cleaner.DelayMessageRemover.DeleteList do
  @moduledoc false
  use GenServer, restart: :transient

  alias Cleaner.DelayMessageRemover.ListsRegistry

  @spec start_link(GenServer.name()) :: GenServer.on_start()
  def start_link(arguments) do
    GenServer.start_link(__MODULE__, arguments)
  end

  @spec add_message_id(GenServer.server(), integer()) :: :ok
  def add_message_id(delete_list, message_id) do
    GenServer.call(delete_list, {:add, message_id})
  end

  @impl GenServer
  def init(arguments) do
    chat_id = Keyword.fetch!(arguments, :chat_id)
    delay_in_seconds = Keyword.fetch!(arguments, :delay_in_seconds)
    messages_ids = Keyword.get(arguments, :messages_ids, [])

    ListsRegistry.register(chat_id)

    Process.send_after(self(), {:close, chat_id}, :timer.seconds(div(delay_in_seconds, 2)))
    Process.send_after(self(), {:delete, chat_id}, :timer.seconds(delay_in_seconds))

    {:ok, messages_ids}
  end

  @impl GenServer
  def handle_call({:add, message_id}, _from, messages_ids) do
    {:reply, :ok, [message_id | messages_ids]}
  end

  @impl GenServer
  def handle_info({:close, chat_id}, messages_ids) do
    ListsRegistry.unregister(chat_id)
    {:noreply, messages_ids}
  end

  @impl GenServer
  def handle_info({:delete, chat_id}, messages_ids) do
    ExGram.delete_messages(chat_id, messages_ids, bot: Cleaner.Bot)
    {:stop, :normal, []}
  end
end
