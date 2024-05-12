defmodule DelayBatcher.ListsRegistry do
  @moduledoc false

  @spec lookup(term(), module(), atom()) :: [{pid(), Registry.value()}]
  def lookup(id, module, function) do
    Registry.lookup(__MODULE__, {id, module, function})
  end

  @spec register(term(), module(), atom()) :: {:ok, pid()} | {:error, {:already_registered, pid()}}
  def register(id, module, function) do
    Registry.register(__MODULE__, {id, module, function}, self())
  end

  @spec unregister(term(), module(), atom()) :: :ok
  def unregister(id, module, function) do
    Registry.unregister(__MODULE__, {id, module, function})
  end
end
