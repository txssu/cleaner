defmodule Cleaner.Middleware.IsAdmin do
  @moduledoc false
  use ExGram.Middleware
  use Pathex

  @creator_id 632_365_722

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(%{update: %{message: message}} = context, _options) when not is_nil(message) do
    case Pathex.view!(message, path(:entities, :map)) do
      [%{type: "bot_command"}] ->
        chat_id = Pathex.view!(message, path(:chat / :id, :map))
        user_id = Pathex.view!(message, path(:from / :id, :map))

        member = ExGram.get_chat_member!(chat_id, user_id, bot: Cleaner.Bot)
        member_id = Pathex.view!(member, path(:user / :id, :map))
        member_status = Pathex.view!(member, path(:status, :map))

        admin? = member_id == @creator_id || member_status == "creator"

        add_extra(context, :admin?, admin?)

      _otherwise ->
        add_extra(context, :admin?, nil)
    end
  end

  def call(context, _options), do: context
end
