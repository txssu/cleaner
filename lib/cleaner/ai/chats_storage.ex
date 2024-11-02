defmodule Cleaner.AI.ChatsStorage do
  @moduledoc false
  use Nebulex.Cache,
    otp_app: :cleaner,
    adapter: Nebulex.Adapters.Local
end
