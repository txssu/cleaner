defmodule Cleaner.BotUtils do
  @moduledoc false
  alias Cleaner.DelayMessageRemover

  require Logger

  @spec answer_and_delete(ExGram.Cnt.t(), String.t(), Keyword.t()) :: :ok | {:error, ExGram.Error.t()}
  def answer_and_delete(context, text, options \\ []) do
    send_options = Keyword.put(options, :bot, Cleaner.Bot)
    chat_id = context.update.message.chat.id

    delay = context.extra.chat_config.delete_delay_in_seconds
    DelayMessageRemover.schedule_delete_message(chat_id, context.update.message.message_id, delay)

    with {:ok, message} = maybe_send_mesage(chat_id, text, send_options) do
      DelayMessageRemover.schedule_delete_message(chat_id, message.message_id, delay)

      :ok
    end
  end

  @spec maybe_send_mesage(integer(), String.t(), Keyword.t()) ::
          {:error, :rate_limit | ExGram.Error.t()} | {:ok, ExGram.Model.Message.t()}
  def maybe_send_mesage(chat_id, text, send_options) do
    case Hammer.check_rate("send_message:#{chat_id}", 60_000, 20) do
      {:allow, _count} ->
        ExGram.send_message(chat_id, text, send_options)

      {:deny, _limit} ->
        {:error, :rate_limit}
    end
  end

  @spec fetch_message(ExGram.Cnt.t()) :: ExGram.Model.Message.t()
  def fetch_message(context)
  def fetch_message(%{update: %{message: message}}), do: message
  def fetch_message(%{update: %{edited_message: message}}), do: message

  def fetch_message(context) do
    Logger.error("Can't fetch message from:\n#{inspect(context, limit: :infinity, pretty: true)}")

    raise "Can't fetch message from event"
  end
end
