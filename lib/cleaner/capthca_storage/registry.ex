defmodule Cleaner.CapthcaStorage.Registry do
  @moduledoc false
  alias Cleaner.CapthcaStorage

  @spec lookup(CapthcaStorage.key()) :: [{pid(), Registry.value()}]
  def lookup(key) do
    Registry.lookup(__MODULE__, key)
  end

  @spec register(CapthcaStorage.key()) :: {:ok, pid()} | {:error, {:already_registered, pid()}}
  def register(key) do
    Registry.register(__MODULE__, key, self())
  end

  @spec unregister(CapthcaStorage.key()) :: :ok
  def unregister(key) do
    Registry.unregister(__MODULE__, key)
  end
end
