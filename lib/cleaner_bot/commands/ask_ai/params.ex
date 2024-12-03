defmodule CleanerBot.Commands.AskAI.Params do
  @moduledoc false
  alias ExGram.Model.Message
  alias ExGram.Model.TextQuote
  alias ExGram.Model.User

  defstruct ~w[user text prompt admin? internal_user reply_to chat_id]a

  defmodule ReplyTo do
    @moduledoc false

    defstruct ~w[message_id text from_username]a

    @type t :: %__MODULE__{
            message_id: integer(),
            text: String.t(),
            from_username: String.t()
          }
  end

  @type t :: %__MODULE__{
          user: User.t(),
          text: String.t(),
          prompt: String.t(),
          admin?: boolean(),
          internal_user: Cleaner.User.t(),
          chat_id: integer(),
          reply_to: ReplyTo.t()
        }

  @spec from_context(ExGram.Cnt.t(), ExGram.Model.Message.t()) :: t()
  def from_context(context, message) do
    %{extra: %{admin?: admin?, chat_config: %{ai_prompt: prompt}, internal_user: internal_user}} = context

    %{chat: %{id: chat_id}, reply_to_message: reply_to, quote: quote_data, from: user} = message
    text = extract_text(message)

    reply_to_bot? = reply_to && reply_to.from.id == context.bot_info.id

    %__MODULE__{
      user: user,
      text: text,
      prompt: prompt,
      admin?: admin?,
      internal_user: internal_user,
      chat_id: chat_id,
      reply_to: transform_reply_to(reply_to, quote_data, reply_to_bot?)
    }
  end

  defp transform_reply_to(reply_message, quote_data, reply_to_bot?)

  defp transform_reply_to(%Message{text: message_text} = message, nil, reply_to_bot?) when is_binary(message_text) do
    text = extract_text(message)

    %ReplyTo{
      message_id: message.message_id,
      text: if(reply_to_bot?, do: nil, else: text),
      from_username: if(reply_to_bot?, do: nil, else: message.from.first_name)
    }
  end

  defp transform_reply_to(%Message{} = message, %TextQuote{} = quote_data, reply_to_bot?) do
    %ReplyTo{
      message_id: message.message_id,
      text: quote_data.text,
      from_username: if(reply_to_bot?, do: nil, else: message.from.first_name)
    }
  end

  defp transform_reply_to(_reply_message, _quote_data, _reply_to_bot?) do
    %ReplyTo{message_id: nil, text: nil}
  end

  defp extract_text(%Message{caption: caption, text: text}) do
    text || caption
  end
end
