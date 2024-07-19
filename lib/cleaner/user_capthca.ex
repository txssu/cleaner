defmodule Cleaner.UserCapthca do
  @moduledoc false
  @keys ~w[chat_id user_id answer]a

  @enforce_keys @keys
  defstruct @keys
end
