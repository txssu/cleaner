defmodule CleanerBot.Commands.AskAI.Params do
  @moduledoc false
  alias ExGram.Model.User

  defstruct ~w[user text prompt admin? model internal_user]a

  @type t :: %__MODULE__{
          user: User.t(),
          text: String.t(),
          prompt: String.t(),
          model: String.t(),
          admin?: boolean(),
          internal_user: Cleaner.User.t()
        }
end
