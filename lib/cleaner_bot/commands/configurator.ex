defmodule CleanerBot.Commands.Configurator do
  @moduledoc false

  alias Cleaner.ChatConfig
  alias CleanerBot.Commands.Configurator.Key

  @allow_keys [
    %Key{name: :ai_prompt, doc: "системный промпт для команды /ask"},
    %Key{name: :delete_delay_in_seconds, short_name: :delete_delay, doc: "количество секунд для таймера на удаление"}
  ]

  @spec call(ChatConfig.t(), String.t(), boolean()) :: String.t()
  def call(chat_config, text, admin?)

  def call(_chat_config, _test, false) do
    "ТОЛЬКА ДЛЯ АДМИНАВ!!!"
  end

  def call(chat_config, text, true) do
    text
    |> parse()
    |> apply_action(chat_config)
    |> format_response()
  end

  defp parse(text) do
    words = String.split(text, " ", trim: true)

    case words do
      ["set", field | value] -> {:ok, {:set, field, Enum.join(value, " ")}}
      ["get", field] -> {:ok, {:get, field}}
      ["list"] -> {:ok, :list}
      ["help"] -> {:ok, :help}
      _other -> {:error, :parse_error}
    end
  end

  defp apply_action({:error, _reason} = error, _chat_config), do: error

  defp apply_action({:ok, {:set, field, value}}, chat_config) do
    with {:ok, key} <- validate_key(field) do
      ChatConfig.save(chat_config, %{key => value})

      {:ok, "Настройки чата успешно обновлены"}
    end
  end

  defp apply_action({:ok, {:get, field}}, chat_config) do
    with {:ok, key} <- validate_key(field) do
      value = chat_config |> Map.fetch!(key) |> to_string()
      {:ok, value}
    end
  end

  defp apply_action({:ok, :list}, _chat_config) do
    text =
      Enum.map_join(@allow_keys, "\n", fn %Key{} = key -> "#{key.short_name || key.name} - #{key.doc}" end)

    {:ok, text}
  end

  defp apply_action({:ok, :help}, _chat_config) do
    {:ok,
     """
     Доступные команды:
     set <field> <value>
     get <field>
     list
     help
     """}
  end

  defp validate_key(field) do
    key = String.to_existing_atom(field)

    Enum.reduce_while(@allow_keys, {:error, :field_not_found}, fn %Key{} = allow_key, acc ->
      if Key.same_atom_key(allow_key, key) do
        {:halt, {:ok, allow_key.name}}
      else
        {:cont, acc}
      end
    end)
  rescue
    _error -> {:error, :field_not_found}
  end

  defp format_response({:ok, response}), do: response
  defp format_response({:error, :parse_error}), do: "Неизвестная команда. Используйте /config help"
  defp format_response({:error, :field_not_found}), do: "Такого поля не существует"
end
