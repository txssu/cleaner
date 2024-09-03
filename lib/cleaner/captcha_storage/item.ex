defmodule Cleaner.CaptchaStorage.Item do
  @moduledoc false
  use GenServer, restart: :transient

  import Cleaner.TgMarkdownUtils

  alias Cleaner.CaptchaStorage
  alias Cleaner.UserCaptcha

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(%UserCaptcha{} = user_capcha) do
    GenServer.start_link(__MODULE__, user_capcha)
  end

  @spec check(pid(), integer(), String.t()) :: :ok
  def check(pid, message_id, text) do
    GenServer.cast(pid, {:check, message_id, text})
  end

  @impl GenServer
  def init(%UserCaptcha{} = user_capcha) do
    CaptchaStorage.Registry.register({user_capcha.chat_id, user_capcha.user.id})
    Process.send_after(self(), :timeout, 60_000)
    {:ok, user_capcha}
  end

  @impl GenServer
  def handle_cast({:check, message_id, text}, %UserCaptcha{} = user_capcha) do
    user_capcha = Map.update!(user_capcha, :messages_ids, &[message_id | &1])

    if text == user_capcha.answer do
      ExGram.delete_messages!(user_capcha.chat_id, user_capcha.messages_ids, bot: CleanerBot.Dispatcher)

      ExGram.send_message!(
        user_capcha.chat_id,
        ~i"[#{user_capcha.user.first_name}](tg://user?id=#{user_capcha.user.id}), добро пожаловать в чат\!",
        parse_mode: "MarkdownV2",
        bot: CleanerBot.Dispatcher
      )

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
    ExGram.delete_messages(user_capcha.chat_id, user_capcha.messages_ids, bot: CleanerBot.Dispatcher)
    ExGram.ban_chat_member(user_capcha.chat_id, user_capcha.user.id, bot: CleanerBot.Dispatcher)

    {:stop, :normal, user_capcha}
  end
end
