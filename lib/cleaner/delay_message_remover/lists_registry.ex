defmodule Cleaner.DelayMessageRemover.ListsRegistry do
  @moduledoc false

  @spec lookup(integer()) :: [{pid(), Registry.value()}]
  def lookup(chat_id) do
    Registry.lookup(__MODULE__, chat_id)
  end

  @spec register(integer()) :: {:ok, pid()} | {:error, {:already_registered, pid()}}
  def register(chat_id) do
    Registry.register(__MODULE__, chat_id, self())
  end

  @spec unregister(integer()) :: :ok
  def unregister(chat_id) do
    Registry.unregister(__MODULE__, chat_id)
  end
end
