defmodule CleanerBot.Commands.SetConfigField do
  @moduledoc false
  use Pathex

  alias Cleaner.ChatConfig
  alias CleanerBot.Commands.SetConfigField.Key

  @allow_keys [
    %Key{name: :ai_prompt, doc: "системный промпт для команды /ask"},
    %Key{name: :delete_delay_in_seconds, short_name: :delete_delay, doc: "количество секунд для таймера на удаление"}
  ]

  @spec call(ChatConfig.t(), String.t(), boolean()) :: {:ok, String.t()} | {:error, atom()}
  def call(chat_config, text, admin?)

  def call(chat_config, text, true) do
    with {:ok, raw_key, value} <- parse_data(text),
         {:ok, key} <- validate_key(raw_key),
         {:ok, _chat_config} <- ChatConfig.save(chat_config, %{key => value}) do
      {:ok, "Настройки чата обновлены"}
    end
  end

  def call(_chat_config, _test, false) do
    "ТОЛЬКА ДЛЯ АДМИНАВ!!!"
  end

  defp parse_data(text) do
    with {:ok, maybe_key, value} <- split_first_word(text),
         {:ok, key} <- to_key(maybe_key) do
      {:ok, key, value}
    end
  end

  defp split_first_word(text) do
    case String.split(text, " ") do
      [word1 | [_word2 | _rest] = rest] -> {:ok, word1, Enum.join(rest, " ")}
      _another -> {:error, :parse_error}
    end
  end

  defp to_key(maybe_key) do
    {:ok, String.to_existing_atom(maybe_key)}
  rescue
    _error -> :error
  end

  defp validate_key(key) do
    Enum.reduce_while(@allow_keys, {:error, :not_found}, fn %Key{} = allow_key, acc ->
      if Key.same_atom_key(allow_key, key) do
        {:halt, {:ok, allow_key.name}}
      else
        {:cont, acc}
      end
    end)
  end
end
