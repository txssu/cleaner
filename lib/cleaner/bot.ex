defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  import Cleaner.BotUtils

  alias Cleaner.ChatConfig

  command("ping", description: "Проверить работает ли бот")
  command("menu", description: "МЕНЮ!!")
  command("setdeletedelay", description: "Установить задержку перед удалением")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(Cleaner.Middleware.FetchChat)
  middleware(Cleaner.Middleware.IsAdmin)

  @spec handle(ExGram.Dispatcher.parsed_message(), ExGram.Cnt.t()) :: ExGram.Cnt.t()
  def handle({:command, :ping, _message}, context) do
    answer_and_delete(context, "pong")
  end

  def handle({:command, :menu, _message}, context) do
    answer_and_delete(context, "/menu")
  end

  def handle({:command, :setdeletedelay, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: true}} = context) do
    case ChatConfig.save(chat_config, %{delete_delay_in_seconds: text}) do
      {:ok, _chat_config} -> answer_and_delete(context, "Готово")
      {:error, _changeset} -> answer_and_delete(context, "Укажите число больше 3")
    end
  end

  def handle({:message, %{dice: %{emoji: emoji, value: value}} = message}, %{extra: %{chat_config: chat_config}} = context) do
    unless winning_dice?(emoji, value) do
      schedule_delete(message.chat.id, message.message_id, chat_config.delete_delay_in_seconds)
    end

    context
  end

  def handle(_event, context), do: context

  defp winning_dice?("🎰", dice_value) do
    <<right::binary-size(2), center::binary-size(2), left::binary-size(2)>> =
      (dice_value - 1)
      |> Integer.to_string(2)
      |> String.pad_leading(6, "0")

    left == center and center == right
  end

  defp winning_dice?(_emoji, dice_value) do
    dice_value == 6
  end
end
