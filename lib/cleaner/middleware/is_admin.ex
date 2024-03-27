defmodule Cleaner.Middleware.IsAdmin do
  @moduledoc false
  use ExGram.Middleware

  alias Cleaner.BotUtils

  @creator_id 632_365_722

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(context, _options) do
    case context.update.message.entities do
      [%{type: "bot_command"}] ->
        chat_id = BotUtils.fetch_message(context).chat.id
        user_id = BotUtils.fetch_message(context).from.id

        member = ExGram.get_chat_member!(chat_id, user_id, bot: Cleaner.Bot)

        admin? =
          member.user.id == @creator_id || member.status == "creator"

        add_extra(context, :admin?, admin?)

      _otherwise ->
        add_extra(context, :admin?, nil)
    end
  end
end
