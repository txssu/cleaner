defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true
  use Pathex

  import Cleaner.BotUtils

  alias Cleaner.Commands
  alias ExGram.Model.ReplyParameters

  command("ping", description: "Проверить работает ли бот")
  command("help", description: "Вызвать помощь")
  command("menu", description: "Вызвать меню")
  command("setdeletedelay", description: "Установить задержку перед удалением")
  command("ask", description: "Задать вопрос мудрецу")
  command("insult", description: "Получить порцию оскорблений")
  command("ask_zhenegi")
  command("del")
  command("info")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(Cleaner.Middleware.FetchChat)
  middleware(Cleaner.Middleware.IsAdmin)

  @spec handle(ExGram.Dispatcher.parsed_message(), ExGram.Cnt.t()) :: ExGram.Cnt.t()
  def handle({:command, :ping, _message}, context) do
    Cleaner.RateLimiter.call(context)
    answer_and_delete(context, "pong")
  end

  def handle({:command, :menu, _message}, context) do
    Cleaner.RateLimiter.call(context)
    answer_and_delete(context, "/menu")
  end

  def handle({:command, :help, _message}, %{extra: %{chat_config: chat_config}} = context) do
    Cleaner.RateLimiter.call(context)
    text = Commands.Help.call(chat_config)
    answer_and_delete(context, text)
  end

  def handle({:command, :setdeletedelay, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: admin?}} = context) do
    Cleaner.RateLimiter.call(context)
    text = Commands.SetDeleteDelay.call(chat_config, text, admin?)
    answer_and_delete(context, text)
  end

  def handle({:command, :ask, %{text: text}}, context) do
    Cleaner.RateLimiter.call(context)
    %{extra: %{admin?: admin?}, update: %{message: %{from: user}}} = context

    case Commands.AskAI.call(user, text, admin?) do
      {:delete, text} -> answer_and_delete(context, text)
      {:no_delete, text} -> answer(context, text)
    end
  end

  def handle({:command, :insult, message}, context) do
    Cleaner.RateLimiter.call(context)

    case Pathex.view(context, path(:update / :message / :reply_to_message / :message_id, :map)) do
      {:ok, reply_to} ->
        text = Commands.Insult.call()

        context
        |> answer(text, reply_parameters: %ReplyParameters{message_id: reply_to})
        |> delete(message)

      :error ->
        answer_and_delete(context, "Используй /insult в ответ на чьё-то сообщение")
    end
  end

  def handle({:command, :ask_zhenegi, %{text: text}}, context) do
    Cleaner.RateLimiter.call(context)
    answer(context, Commands.AskZhenegi.call(text))
  end

  def handle({:command, :info, _message}, context) do
    admin? = Pathex.view!(context, path(:extra / :admin?))

    if admin? do
      answer(context, Commands.Info.call(context))
    else
      context
    end
  end

  def handle({:command, :del, message}, context) do
    admin? = Pathex.view!(context, path(:extra / :admin?))

    if admin? do
      reply = Pathex.view!(context, path(:update / :message / :reply_to_message, :map))

      context
      |> delete(message)
      |> delete(reply)
    else
      context
    end
  end

  def handle({:message, %{dice: dice} = message}, %{extra: %{chat_config: chat_config}} = context) do
    Commands.DeleteLosingDice.call(chat_config, message, dice)

    context
  end

  def handle(_event, context), do: context
end
