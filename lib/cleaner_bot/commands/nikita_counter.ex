defmodule CleanerBot.Commands.NikitaCounter do
  @moduledoc false
  import ExGram.Dsl.Keyboard

  alias ExGram.Model.Message

  require ExGram.Dsl.Keyboard

  @chat_id Application.compile_env(:cleaner, [__MODULE__, :chat_id], 0)
  @user_id Application.compile_env(:cleaner, [__MODULE__, :user_id])
  @user_birth_day ~D[2005-02-10]
  @timeout :timer.minutes(30)

  @spec cron() :: any()
  def cron do
    markup =
      keyboard :inline do
        row do
          button("Да", callback_data: "yes")
          button("Нет", callback_data: "no")
        end
      end

    message =
      ExGram.send_message!(@chat_id, "[Никита](tg://user?id=#{@user_id}), ты сегодня занялся сексом?",
        reply_markup: markup,
        parse_mode: "MarkdownV2",
        bot: CleanerBot.Dispatcher
      )

    Task.async(fn -> timeout(message) end)

    :ok
  end

  @spec call(integer(), String.t()) :: :ignore | {:answer, String.t()}
  def call(user_id, answer) do
    if user_id == @user_id do
      if pid = Process.whereis(__MODULE__) do
        Process.exit(pid, :kill)
      end

      {:answer, handle_answer(answer)}
    else
      :ignore
    end
  end

  defp timeout(%Message{} = message) do
    Process.register(self(), __MODULE__)

    Process.sleep(@timeout)

    ExGram.edit_message_text("#{message.text}\nВремя на ответ истекло.",
      chat_id: message.chat.id,
      message_id: message.message_id,
      bot: CleanerBot.Dispatcher
    )

    ExGram.send_message(@chat_id, "Никита. #{day_without_counter()}", bot: CleanerBot.Dispatcher)
  end

  defp handle_answer("yes") do
    "Никита, зачем ты ответил, что у тебя был секс? Ты хотя бы себя не обманывай.\n#{day_without_counter()}"
  end

  defp handle_answer("no") do
    "Никита. #{day_without_counter()}"
  end

  defp day_without_counter do
    days = Date.diff(Date.utc_today(), @user_birth_day)

    "День без секса #{days}."
  end
end
