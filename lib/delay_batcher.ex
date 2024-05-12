defmodule DelayBatcher do
  @moduledoc false

  alias DelayBatcher.List
  alias DelayBatcher.ListsRegistry
  alias DelayBatcher.ListsSupervisor

  @spec delay_action(term(), {module(), atom()}, item, integer(), integer()) :: any() when item: term()
  def delay_action(id, {module, function} = mf, item, close_after, perform_after) do
    case ListsRegistry.lookup(id, module, function) do
      [{_key, list}] ->
        List.append(list, item)

      [] ->
        ListsSupervisor.start_child(
          id: id,
          action: mf,
          items: [item],
          close_after: close_after,
          perform_after: perform_after
        )
    end
  end
end
