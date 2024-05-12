defmodule DelayBatcher.Supervisor do
  @moduledoc false
  use Supervisor

  alias DelayBatcher.ListsRegistry
  alias DelayBatcher.ListsSupervisor

  @spec start_link(any()) ::
          {:ok, pid()}
          | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl Supervisor
  def init(_init_arg) do
    children = [
      ListsSupervisor,
      {Registry, name: ListsRegistry, keys: :unique}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
