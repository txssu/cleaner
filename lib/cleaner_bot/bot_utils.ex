defmodule CleanerBot.Utils do
  @moduledoc false
  use Pathex

  alias CleanerBot.DelayMessageRemover

  require Logger

  @spec answer_and_delete(ExGram.Cnt.t(), String.t(), Keyword.t()) :: :ok | {:error, ExGram.Error.t()}
  def answer_and_delete(context, text, options \\ []) do
    send_options = Keyword.put(options, :bot, CleanerBot.Dispatcher)

    chat_id = Pathex.view!(context, path(:update / :message / :chat / :id, :map))
    message_id = Pathex.view!(context, path(:update / :message / :message_id, :map))
    delay = Pathex.view!(context, path(:extra / :chat_config / :delete_delay_in_seconds, :map))

    DelayMessageRemover.schedule_delete_message(chat_id, message_id, delay)

    with {:ok, %{message_id: sended_message_id}} <- ExGram.send_message(chat_id, text, send_options) do
      DelayMessageRemover.schedule_delete_message(chat_id, sended_message_id, delay)

      :ok
    end
  end
end
