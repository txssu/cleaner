defmodule Cleaner.BotUtils do
  @moduledoc false
  alias Cleaner.MessageRemover

  @spec answer_and_delete(ExGram.Cnt.t(), String.t(), Keyword.t()) :: :ok | {:error, ExGram.Error.t()}
  def answer_and_delete(context, text, options \\ []) do
    send_options = Keyword.put(options, :bot, Cleaner.Bot)
    chat_id = context.update.message.chat.id

    with {:ok, message} = ExGram.send_message(chat_id, text, send_options) do
      schedule_delete(chat_id, message.message_id, context.extra.chat_config.delete_delay_in_seconds)
      schedule_delete(chat_id, context.update.message.message_id, context.extra.chat_config.delete_delay_in_seconds)
      :ok
    end
  end

  @spec schedule_delete(integer(), integer(), integer()) :: {:ok, Oban.Job.t()} | {:error, Oban.Job.changeset() | term()}
  def schedule_delete(chat_id, message_id, schedule_in) do
    %{chat_id: chat_id, message_id: message_id}
    |> MessageRemover.new(schedule_in: schedule_in)
    |> Oban.insert()
  end
end
