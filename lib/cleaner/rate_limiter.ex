defmodule Cleaner.RateLimiter do
  @moduledoc false
  use Pathex

  alias Cleaner.DelayMessageRemover

  @spec call(ExGram.Cnt.t()) :: :ok
  def call(context) do
    chat_id = Pathex.view!(context, path(:update / :message / :chat / :id, :map))

    case Hammer.check_rate("send_message:#{chat_id}", 60_000, 20) do
      {:allow, _count} ->
        :ok

      {:deny, _limit} ->
        message_id = Pathex.view!(context, path(:update / :message / :message_id, :map))
        delay = Pathex.view!(context, path(:extra / :chat_config / :delete_delay_in_seconds, :map))
        DelayMessageRemover.schedule_delete_message(chat_id, message_id, delay)
        raise "Spammer in #{chat_id}"
    end
  end
end
