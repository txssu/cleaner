defmodule Cleaner.Middleware.IsAdmin do
  @moduledoc false
  use ExGram.Middleware

  @creator_id 632_365_722

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(%{update: %{message: message}} = context, _options) when not is_nil(message) do
    case message.entities do
      [%{type: "bot_command"}] ->
        chat_id = message.chat.id
        user_id = message.from.id

        member = ExGram.get_chat_member!(chat_id, user_id, bot: Cleaner.Bot)

        admin? =
          member.user.id == @creator_id || member.status == "creator"

        add_extra(context, :admin?, admin?)

      _otherwise ->
        add_extra(context, :admin?, nil)
    end
  end

  def call(context, _options), do: context
end
