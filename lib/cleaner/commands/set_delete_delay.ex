defmodule Cleaner.Commands.SetDeleteDelay do
  @moduledoc false
  alias Cleaner.ChatConfig

  @spec call(ChatConfig.t(), String.t(), boolean()) :: String.t()
  def call(chat_config, text, admin?)

  def call(chat_config, text, true) do
    case ChatConfig.save(chat_config, %{delete_delay_in_seconds: text}) do
      {:ok, chat_config} -> "Установлено удаление после #{chat_config.delete_delay_in_seconds} сек."
      {:error, _changeset} -> "Укажите число больше 3"
    end
  end

  def call(_chat_config, _test, false) do
    "ТОЛЬКА ДЛЯ АДМИНАВ!!!"
  end
end
