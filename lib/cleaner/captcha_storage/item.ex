defmodule Cleaner.CaptchaStorage.Item do
  @moduledoc false
  use GenServer, restart: :transient

  alias Cleaner.CaptchaStorage
  alias Cleaner.UserCaptcha

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(%UserCaptcha{} = user_capcha) do
    GenServer.start_link(__MODULE__, user_capcha)
  end

  @spec check(pid(), String.t()) :: :ok
  def check(pid, text) do
    GenServer.cast(pid, {:check, text})
  end

  @impl GenServer
  def init(%UserCaptcha{} = user_capcha) do
    CaptchaStorage.Registry.register({user_capcha.chat_id, user_capcha.user_id})
    Process.send_after(self(), :timeout, 60_000)
    {:ok, user_capcha}
  end

  @impl GenServer
  def handle_cast({:check, text}, %UserCaptcha{} = user_capcha) do
    if text == user_capcha.answer do
      ExGram.send_message(user_capcha.chat_id, "Проверка пройдена", bot: CleanerBot.Dispatcher)
      {:stop, :normal, user_capcha}
    else
      close(user_capcha)
    end
  end

  @impl GenServer
  def handle_info(:timeout, %UserCaptcha{} = user_capcha) do
    close(user_capcha)
  end

  defp close(%UserCaptcha{} = user_capcha) do
    ExGram.send_message(user_capcha.chat_id, "Кик ботяру", bot: CleanerBot.Dispatcher)
    ExGram.ban_chat_member(user_capcha.chat_id, user_capcha.user_id, bot: CleanerBot.Dispatcher)

    {:stop, :normal, user_capcha}
  end
end
