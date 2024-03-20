defmodule Cleaner.Middleware.IsAdmin do
  @moduledoc false
  use ExGram.Middleware

  @creator_id 632365722

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(context, _options) do
    case context.update.message.entities do
      [%{type: "bot_command"}] ->
        chat_id = context.update.message.chat.id
        user_id = context.update.message.from.id

        member = ExGram.get_chat_member!(chat_id, user_id, bot: Cleaner.Bot)
        admin? = member.user.id == @creator_id || member.status == "creator" || (member.status == "administrator" && member.can_manage_chat)

        add_extra(context, :admin?, admin?)

      _otherwise ->
        add_extra(context, :admin?, nil)
    end
  end
end
