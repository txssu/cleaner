defmodule CleanerBot.TypingSender do
  @moduledoc false
  use GenServer

  @typing_interval 5000
  @bot CleanerBot.Dispatcher

  @spec start_link(integer()) :: GenServer.on_start()
  def start_link(chat_id) do
    GenServer.start_link(__MODULE__, chat_id)
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end

  @impl GenServer
  def init(chat_id) do
    {:ok, chat_id, {:continue, :send_initial_typing}}
  end

  @impl GenServer
  def handle_continue(:send_initial_typing, chat_id) do
    ExGram.send_chat_action!(chat_id, "typing", bot: @bot)
    schedule_typing()
    {:noreply, chat_id}
  end

  @impl GenServer
  def handle_info(:send_typing, chat_id) do
    ExGram.send_chat_action!(chat_id, "typing", bot: @bot)

    schedule_typing()
    {:noreply, chat_id}
  end

  defp schedule_typing do
    Process.send_after(self(), :send_typing, @typing_interval)
  end
end
