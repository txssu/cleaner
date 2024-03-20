defmodule Cleaner.MessageRemover do
  @moduledoc false
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"chat_id" => chat_id, "message_id" => message_id}}) do
    ExGram.delete_message(chat_id, message_id, bot: Cleaner.Bot)
  end
end
