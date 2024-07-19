defmodule Cleaner.UserCapthca do
  @moduledoc false
  @keys ~w[chat_id user_id answer]a

  @enforce_keys @keys
  defstruct @keys

  @type t :: %__MODULE__{
          chat_id: integer(),
          user_id: integer(),
          answer: String.t()
        }
end
