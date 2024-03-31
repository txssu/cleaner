defmodule Cleaner.Commands.Help do
  @moduledoc false

  alias Cleaner.ChatConfig

  @spec call(ChatConfig.t()) :: String.t()
  def call(chat_config) do
    help_text =
      [
        "ПОМГАЮ!!!",
        "Срочно звоню в 112",
        "Загугли",
        "#неосилятор",
        "У чатгпт спроси"
      ]
      |> Kernel.--([chat_config.last_help_message])
      |> Enum.random()

    ChatConfig.save(chat_config, %{last_help_message: help_text})

    help_text
  end
end
