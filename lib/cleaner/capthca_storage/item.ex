defmodule Cleaner.CapthcaStorage.Item do
  @moduledoc false
  use GenServer, restart: :transient

  alias Cleaner.CapthcaStorage
  alias Cleaner.UserCapthca

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(%UserCapthca{} = user_capcha) do
    GenServer.start_link(__MODULE__, user_capcha)
  end

  def check(pid, text) do
    GenServer.cast(pid, {:check, text})
  end

  @impl GenServer
  def init(%UserCapthca{} = user_capcha) do
    CapthcaStorage.Registry.register({user_capcha.chat_id, user_capcha.user_id})
    Process.send_after(self(), :timeout, 60_000)
    {:ok, user_capcha}
  end

  @impl GenServer
  def handle_cast({:check, text}, %UserCapthca{} = user_capcha) do
    if text == user_capcha.answer do
      ExGram.send_message(user_capcha.chat_id, "Проверка пройдена", bot: CleanerBot.Dispatcher)
      {:stop, :normal, user_capcha}
    else
      close(user_capcha)
    end
  end

  @impl GenServer
  def handle_info(:timeout, %UserCapthca{} = user_capcha) do
    close(user_capcha)
  end

  def close(%UserCapthca{} = user_capcha) do
    ExGram.send_message(user_capcha.chat_id, "Кик ботяру", bot: CleanerBot.Dispatcher)
    ExGram.ban_chat_member(user_capcha.chat_id, user_capcha.user_id, bot: CleanerBot.Dispatcher)

    {:stop, :normal, user_capcha}
  end
end
