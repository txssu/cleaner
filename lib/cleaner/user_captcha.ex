defmodule Cleaner.UserCaptcha do
  @moduledoc false
  @keys ~w[chat_id user answer messages_ids]a

  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          chat_id: integer(),
          user: ExGram.Model.User.t(),
          answer: String.t(),
          messages_ids: [integer()]
        }
end
