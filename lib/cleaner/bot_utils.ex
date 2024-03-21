defmodule Cleaner.BotUtils do
  @moduledoc false
  alias Cleaner.DelayMessageRemover

  @spec answer_and_delete(ExGram.Cnt.t(), String.t(), Keyword.t()) :: :ok | {:error, ExGram.Error.t()}
  def answer_and_delete(context, text, options \\ []) do
    send_options = Keyword.put(options, :bot, Cleaner.Bot)
    chat_id = context.update.message.chat.id

    with {:ok, message} = ExGram.send_message(chat_id, text, send_options) do
      delay = context.extra.chat_config.delete_delay_in_seconds
      DelayMessageRemover.schedule_delete_message(chat_id, message.message_id, delay)
      DelayMessageRemover.schedule_delete_message(chat_id, context.update.message.message_id, delay)

      :ok
    end
  end
end
