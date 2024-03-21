defmodule Cleaner.DelayMessageRemover.ListsSupervisor do
  @moduledoc false
  use DynamicSupervisor

  alias Cleaner.DelayMessageRemover.DeleteList

  @spec start_child(Keyword.t()) :: Supervisor.on_start_child()
  def start_child(arguments) do
    DynamicSupervisor.start_child(__MODULE__, {DeleteList, arguments})
  end

  @spec start_link(any()) :: Supervisor.on_start()
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
