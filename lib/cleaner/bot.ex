defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  import Cleaner.BotUtils

  alias Cleaner.ChatConfig
  alias Cleaner.DelayMessageRemover

  command("ping", description: "Проверить работает ли бот")
  command("help", description: "Вызвать помощь")
  command("menu", description: "Вызвать меню")
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

  def handle({:command, :help, _message}, context) do
    help_text =
      Enum.random([
        "ПОМГАЮ!!!",
        "Срочно звоню в 112",
        "Загугли",
        "#неосилятор",
        "У чатгпт спроси"
      ])

    answer_and_delete(context, help_text)
  end

  def handle({:command, :setdeletedelay, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: true}} = context) do
    case ChatConfig.save(chat_config, %{delete_delay_in_seconds: text}) do
      {:ok, _chat_config} -> answer_and_delete(context, "Готово")
      {:error, _changeset} -> answer_and_delete(context, "Укажите число больше 3")
    end
  end

  def handle({:command, :setdeletedelay, _message}, %{extra: %{admin?: false}} = context) do
    answer_and_delete(context, "ТОЛЬКА ДЛЯ АДМИНАВ!!!")
  end

  def handle({:message, %{dice: dice} = message}, %{extra: %{chat_config: chat_config}} = context) do
    unless winning_dice?(dice) do
      DelayMessageRemover.schedule_delete_message(
        message.chat.id,
        message.message_id,
        chat_config.delete_delay_in_seconds
      )
    end

    context
  end

  def handle(_event, context), do: context

  defp winning_dice?(%{emoji: "🎰", value: dice_value}) do
    <<right::binary-size(2), center::binary-size(2), left::binary-size(2)>> =
      (dice_value - 1)
      |> Integer.to_string(2)
      |> String.pad_leading(6, "0")

    left == center and center == right
  end

  @winning_value %{
    "🎯" => 6,
    "🎳" => 6,
    "🎲" => 6,
    "⚽" => 5,
    "🏀" => 5
  }

  defp winning_dice?(%{emoji: emoji, value: dice_value}) do
    %{^emoji => winning_value} = @winning_value
    winning_value == dice_value
  end
end
