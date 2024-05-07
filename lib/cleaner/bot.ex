defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  import Cleaner.BotUtils

  alias Cleaner.Commands

  command("ping", description: "Проверить работает ли бот")
  command("help", description: "Вызвать помощь")
  command("menu", description: "Вызвать меню")
  command("setdeletedelay", description: "Установить задержку перед удалением")
  command("ask", description: "Задать вопрос мудрецу")
  command("insult", description: "Получить порцию оскорблений")
  command("ask_zhenegi")

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

  def handle({:command, :help, _message}, %{extra: %{chat_config: chat_config}} = context) do
    text = Commands.Help.call(chat_config)
    answer_and_delete(context, text)
  end

  def handle({:command, :setdeletedelay, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: admin?}} = context) do
    text = Commands.SetDeleteDelay.call(chat_config, text, admin?)
    answer_and_delete(context, text)
  end

  def handle({:command, :ask, %{text: text}}, context) do
    %{extra: %{admin?: admin?}, update: %{message: %{from: user}}} = context

    case Commands.AskAI.call(user, text, admin?) do
      {:delete, text} -> answer_and_delete(context, text)
      {:no_delete, text} -> answer(context, text)
    end
  end

  def handle({:command, :insult, _message}, context) do
    answer(context, Commands.Insult.call())
  end

  def handle({:command, :ask_zhenegi, %{text: text}}, context) do
    answer(context, Commands.AskZhenegi.call(text), disable_notification: true)
  end

  def handle({:message, %{dice: dice} = message}, %{extra: %{chat_config: chat_config}} = context) do
    Commands.DeleteLosingDice.call(chat_config, message, dice)

    context
  end

  def handle(_event, context), do: context
end
