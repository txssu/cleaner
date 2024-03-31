defmodule Cleaner.Commands.Help do
  @moduledoc false

  use Pathex

  alias Cleaner.ChatConfig

  @spec call(ChatConfig.t()) :: String.t()
  def call(chat_config) do
    last_help_message = Pathex.view!(chat_config, path(:last_help_message))

    help_text =
      [
        "ПОМГАЮ!!!",
        "Срочно звоню в 112",
        "Загугли",
        "#неосилятор",
        "У чатгпт спроси"
      ]
      |> Kernel.--([last_help_message])
      |> Enum.random()

    ChatConfig.save(chat_config, %{last_help_message: help_text})

    help_text
  end
end
