defmodule CleanerBot.DelayMessageRemover do
  @moduledoc false

  @spec schedule_delete_message(integer(), integer(), integer()) :: any()
  def schedule_delete_message(chat_id, message_id, delay_in_seconds) do
    DelayBatcher.delay_action(
      chat_id,
      {__MODULE__, :delete_messages},
      message_id,
      :timer.seconds(div(delay_in_seconds, 2)),
      :timer.seconds(delay_in_seconds)
    )
  end

  @spec delete_messages(integer(), [integer()]) :: any()
  def delete_messages(chat_id, messages_ids) do
    ExGram.delete_messages!(chat_id, messages_ids, bot: CleanerBot.Dispatcher)
  end
end
