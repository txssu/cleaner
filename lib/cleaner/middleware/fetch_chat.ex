defmodule Cleaner.Middleware.FetchChat do
  @moduledoc false
  use ExGram.Middleware

  alias Cleaner.ChatConfig

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(context, _options) do
    chat_id = context.update.message.chat.id
    chat_config = ChatConfig.get_by_id_or_new(chat_id)

    add_extra(context, :chat_config, chat_config)
  end
end
