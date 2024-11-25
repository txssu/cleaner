defmodule CleanerBot.Commands.AskAI.Params do
  @moduledoc false
  alias ExGram.Model.User

  defstruct ~w[user text prompt admin? internal_user reply_to chat_id]a

  @type t :: %__MODULE__{
          user: User.t(),
          text: String.t(),
          prompt: String.t(),
          admin?: boolean(),
          internal_user: Cleaner.User.t(),
          chat_id: integer(),
          reply_to: integer()
        }

  @spec from_context(map()) :: t()
  def from_context(context) do
    %{
      extra: %{admin?: admin?, chat_config: %{ai_prompt: prompt}, internal_user: internal_user},
      update: %{message: %{chat: %{id: chat_id}, text: text, reply_to_message: reply_to, from: user}}
    } =
      context

    %__MODULE__{
      user: user,
      text: text,
      prompt: prompt,
      admin?: admin?,
      internal_user: internal_user,
      chat_id: chat_id,
      reply_to: reply_to && reply_to.message_id
    }
  end
end
