defmodule Cleaner.DelayMessageRemover do
  @moduledoc false
  alias Cleaner.DelayMessageRemover.DeleteList
  alias Cleaner.DelayMessageRemover.ListsRegistry
  alias Cleaner.DelayMessageRemover.ListsSupervisor

  @spec schedule_delete_message(integer(), integer(), integer()) :: any()
  def schedule_delete_message(chat_id, message_id, delay_in_seconds) do
    case ListsRegistry.lookup(chat_id) do
      [{_key, list}] ->
        DeleteList.add_message_id(list, message_id)

      [] ->
        ListsSupervisor.start_child(chat_id: chat_id, delay_in_seconds: delay_in_seconds, messages_ids: [message_id])
    end
  end
end
