defmodule CleanerBot.Dispatcher do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true
  use Pathex

  import CleanerBot.Utils

  alias CleanerBot.Commands
  alias ExGram.Model.ReplyParameters

  command("ping", description: "Проверить работает ли бот")
  command("help", description: "Вызвать помощь")
  command("menu", description: "Вызвать меню")
  command("setdeletedelay", description: "Установить задержку перед удалением")
  command("setaiprompt", description: "Установить промпт для /ask")
  command("ask", description: "Задать вопрос мудрецу")
  command("ask4o", description: "Задать вопрос НАСТОЯЩЕМУ мудрецу")
  command("insult", description: "Получить порцию оскорблений")
  command("privacy", description: "Политика конфиденциальности")
  command("ask_zhenegi")
  command("del")
  command("info")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(CleanerBot.Middlewares.FetchChat)
  middleware(CleanerBot.Middlewares.IsAdmin)

  @spec handle(ExGram.Dispatcher.parsed_message(), ExGram.Cnt.t()) :: ExGram.Cnt.t()
  def handle({:command, :ping, _message}, context) do
    CleanerBot.RateLimiter.call(context)
    answer_and_delete(context, "pong")
  end

  def handle({:command, :menu, _message}, context) do
    CleanerBot.RateLimiter.call(context)
    answer_and_delete(context, "/menu")
  end

  def handle({:command, :privacy, _message}, context) do
    CleanerBot.RateLimiter.call(context)

    answer_and_delete(context, """
    Используя данного бота, вы автоматически соглашаетесь с тем, что:
    1. Сбор данных: Мы можем собирать любые данные, которые вы предоставляете в рамках использования данного бота.
    2. Хранение данных: Все собранные данные могут храниться в течение 50 лет с момента их получения.
    3. Использование данных: Мы можем использовать собранные данные для любых целей.
    4. Согласие: Использование данного бота означает ваше автоматическое согласие с данной Политикой конфиденциальности.
    """)
  end

  def handle({:command, :help, _message}, %{extra: %{chat_config: chat_config}} = context) do
    CleanerBot.RateLimiter.call(context)
    text = Commands.Help.call(chat_config)
    answer_and_delete(context, text)
  end

  def handle({:command, :setdeletedelay, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: admin?}} = context) do
    CleanerBot.RateLimiter.call(context)
    text = Commands.SetDeleteDelay.call(chat_config, text, admin?)
    answer_and_delete(context, text)
  end

  def handle({:command, :setaiprompt, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: admin?}} = context) do
    CleanerBot.RateLimiter.call(context)
    text = Commands.SetAIPrompt.call(chat_config, text, admin?)
    answer_and_delete(context, text)
  end

  def handle({:command, command, %{text: text}}, context) when command in [:ask, :ask4o] do
    CleanerBot.RateLimiter.call(context)
    %{extra: %{admin?: admin?, chat_config: %{ai_prompt: prompt}}, update: %{message: %{from: user}}} = context

    model =
      case command do
        :ask -> "gpt-3.5-turbo-0125"
        :ask4o -> "gpt-4o"
      end

    case Commands.AskAI.call(user, text, prompt, admin?, model) do
      {:delete, text} -> answer_and_delete(context, text)
      {:no_delete, text} -> answer(context, text)
    end
  end

  def handle({:command, :insult, message}, context) do
    CleanerBot.RateLimiter.call(context)

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
    CleanerBot.RateLimiter.call(context)
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

  def handle({:callback_query, callback_query}, context) do
    dbg(callback_query)
    user_id = Pathex.view!(callback_query, path(:from / :id, :map))
    answer = Pathex.view!(callback_query, path(:data, :map))
    message = Pathex.view!(callback_query, path(:message, :map))

    context = answer_callback(context, callback_query)

    case Commands.NikitaCounter.call(user_id, answer) do
      :ignore ->
        context

      {:answer, text} ->
        context
        |> edit(:inline, "#{message.text}\nОтвет дан.")
        |> answer(text, reply_parameters: %ReplyParameters{message_id: message.message_id})
    end
  end

  def handle({:message, %{dice: dice} = message}, %{extra: %{chat_config: chat_config}} = context) do
    Commands.DeleteLosingDice.call(chat_config, message, dice)

    context
  end

  def handle(_event, context), do: context
end
