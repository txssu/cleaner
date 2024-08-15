defmodule Cleaner.CaptchaStorage.Registry do
  @moduledoc false
  alias Cleaner.CaptchaStorage

  @spec lookup(CaptchaStorage.key()) :: [{pid(), Registry.value()}]
  def lookup(key) do
    Registry.lookup(__MODULE__, key)
  end

  @spec register(CaptchaStorage.key()) :: {:ok, pid()} | {:error, {:already_registered, pid()}}
  def register(key) do
    Registry.register(__MODULE__, key, self())
  end

  @spec unregister(CaptchaStorage.key()) :: :ok
  def unregister(key) do
    Registry.unregister(__MODULE__, key)
  end
end
