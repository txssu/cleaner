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
end
