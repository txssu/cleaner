defmodule Cleaner.Commands.SetAIPrompt do
  @moduledoc false
  use Pathex

  alias Cleaner.ChatConfig

  @spec call(ChatConfig.t(), String.t(), boolean()) :: String.t()
  def call(chat_config, text, admin?)

  def call(chat_config, text, true) do
    case ChatConfig.save(chat_config, %{ai_prompt: text}) do
      {:ok, _chat_config} ->
        "Новый промпт установлен успешно"
    end
  end

  def call(_chat_config, _test, false) do
    "ТОЛЬКА ДЛЯ АДМИНАВ!!!"
  end
end
