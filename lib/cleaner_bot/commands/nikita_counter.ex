defmodule CleanerBot.Commands.NikitaCounter do
  @moduledoc false

  import ExGram.Dsl.Keyboard

  require ExGram.Dsl.Keyboard

  @chat_id Application.compile_env(:cleaner, [__MODULE__, :chat_id])
  @user_id Application.compile_env(:cleaner, [__MODULE__, :user_id])
  @user_birth_day ~D[2005-02-10]

  @spec cron() :: any()
  def cron do
    markup =
      keyboard :inline do
        row do
          button("Да", callback_data: "yes")
          button("Нет", callback_data: "no")
        end
      end

    ExGram.send_message(@chat_id, "[Никита](tg://user?id=#{@user_id}), ты сегодня занялся сексом?",
      reply_markup: markup,
      parse_mode: "MarkdownV2",
      bot: CleanerBot.Dispatcher
    )
  end

  @spec call(integer(), String.t()) :: :ignore | {:answer, String.t()}
  def call(user_id, answer) do
    dbg(user_id)

    if user_id == @user_id do
      {:answer, handle_answer(answer)}
    else
      :ignore
    end
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
