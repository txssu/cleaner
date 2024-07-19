defmodule Cleaner.CapthcaStorage do
  @moduledoc false
  alias Cleaner.CapthcaStorage
  alias Cleaner.UserCapthca

  @type key :: {integer(), integer()}

  @spec create(Cleaner.UserCapthca.t()) :: Supervisor.on_start_child()
  def create(%UserCapthca{} = user_capcha) do
    CapthcaStorage.DynamicSupervisor.start_child(user_capcha)
  end

  @spec check(integer(), integer(), String.t()) :: :ok
  def check(chat_id, user_id, text) do
    case CapthcaStorage.Registry.lookup({chat_id, user_id}) do
      [] -> nil
      [{pid, _value}] -> CapthcaStorage.Item.check(pid, text)
    end

    :ok
  end
end
