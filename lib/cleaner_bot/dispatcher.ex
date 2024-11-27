defmodule CleanerBot.Dispatcher do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true
  use Pathex

  import CleanerBot.Utils

  alias CleanerBot.Commands
  alias ExGram.Model.InlineQueryResultArticle
  alias ExGram.Model.InputTextMessageContent
  alias ExGram.Model.ReplyParameters

  @v Cleaner.Version.get_version()

  command("ping", description: "Проверить работает ли бот")
  command("help", description: "Вызвать помощь")
  command("menu", description: "Вызвать меню")
  command("config", description: "Обновить настройки чата")
  command("ask", description: "Задать вопрос мудрецу")
  command("insult", description: "Получить порцию оскорблений")
  command("privacy", description: "Политика конфиденциальности")
  command("del")
  command("info")
  command("v")

  middleware(ExGram.Middleware.IgnoreUsername)
  middleware(CleanerBot.Middlewares.FetchChat)
  middleware(CleanerBot.Middlewares.FetchUser)
  middleware(CleanerBot.Middlewares.IsAdmin)

  @spec handle(ExGram.Dispatcher.parsed_message(), ExGram.Cnt.t()) :: ExGram.Cnt.t()
  def handle({:text, _text, %ExGram.Model.Message{} = message}, context) do
    if user = message.from do
      Commands.Captcha.check(user, message, context)
    end
  end

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

  def handle({:command, :config, %{text: text}}, %{extra: %{chat_config: chat_config, admin?: admin?}} = context) do
    CleanerBot.RateLimiter.call(context)

    response = Commands.Configurator.call(chat_config, text, admin?)

    answer_and_delete(context, response)
  end

  def handle({:command, :ask, message}, context) do
    CleanerBot.RateLimiter.call(context)

    command_params = Commands.AskAI.Params.from_context(context, message)
    reply_params = %ReplyParameters{message_id: message.message_id}

    case Commands.AskAI.call(command_params) do
      {:delete, text} ->
        answer_and_delete(context, text, reply_parameters: reply_params)

      {:no_delete, text, callback} ->
        message =
          ExGram.send_message!(context.update.message.chat.id, text, bot: __MODULE__, reply_parameters: reply_params)

        callback.(message)
        context
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

  def handle({:command, :v, _message}, context) do
    answer_and_delete(context, @v)
  end

  def handle({:callback_query, callback_query}, context) do
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

  def handle({:message, %{dice: dice} = message}, %{extra: %{chat_config: chat_config}} = context)
      when not is_nil(dice) do
    Commands.DeleteLosingDice.call(chat_config, message, dice)

    context
  end

  def handle({:message, %{new_chat_members: new_members}}, context) when not is_nil(new_members) do
    Enum.reduce(new_members, context, fn member, context ->
      Commands.Captcha.call(context, member)
    end)
  end

  def handle({:inline_query, %{query: ""}}, context) do
    context
  end

  def handle({:inline_query, inline_query}, context) do
    kolovrat = Commands.Kolovrat.call(inline_query.query)

    answer_inline_query(
      context,
      [
        %InlineQueryResultArticle{
          type: "article",
          id: inline_query.id,
          title: "Коловрат",
          description: "Нажми, чтобы сгенерировать ASCII-арт с шаблоном коловрата",
          input_message_content: %InputTextMessageContent{
            message_text: kolovrat,
            parse_mode: "MarkdownV2"
          }
        }
      ],
      cache_time: 0
    )
  end

  def handle(_event, context), do: context
end
