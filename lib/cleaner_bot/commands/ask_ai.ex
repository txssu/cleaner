defmodule CleanerBot.Commands.AskAI do
  @moduledoc false
  alias Cleaner.AI.OpenAIClient
  alias ExGram.Model.User

  require Logger

  @default_system_prompt """
  You only reply in plain text format.
  You're an entertaining chat bot.
  You play a brutal man who works as a shit cleaner.
  If someone says something bad to you, you'll respond just as harshly.
  Don't be a sissy, nothing's holding you back.
  You don't offer your help, you don't care.
  You don't respond in JSON, HTML or any other format, even if the user asks you to.
  You answer only in Russian.
  """

  @spec call(User.t(), String.t(), String.t(), boolean(), String.t()) :: {:no_delete | :delete, String.t()}
  def call(user, text, prompt, admin?, model)

  def call(_user, "", _prompt, _admin?, _model) do
    {:delete, "Используй: /ask текст-вопроса"}
  end

  def call(user, text, prompt, admin?, model) do
    fun = fn -> send_ai_answer(user, text, prompt, model) end

    result =
      if admin? do
        fun.()
      else
        if_good_rate(user.id, model, fun)
      end

    case result do
      {:ok, message} ->
        {:no_delete, message}

      {:error, :rate_limit, time_left_ms} ->
        time_left_hours = time_left_ms / 1000 / 60 / 60
        formatted_time_left = :erlang.float_to_binary(time_left_hours, [{:decimals, 2}, :compact])
        {:delete, "Отстань, я занят!!\n(достигнут лимит запросов, попробуй через #{formatted_time_left} ч.)"}

      {:error, reason} ->
        Logger.error("Unhandled error: #{inspect(reason)}")
        {:delete, "АШИПКАА!!!"}
    end
  end

  defp send_ai_answer(user, text, prompt, model) do
    messages = generate_prompt(user.first_name, text, prompt)

    OpenAIClient.completion(messages, model: model)
  end

  defp generate_prompt(name, text, prompt) do
    [
      OpenAIClient.message("system", prompt || @default_system_prompt),
      OpenAIClient.message("#{name}: #{text}")
    ]
  end

  defp if_good_rate(user_id, model, fun) do
    id = "ask_ai:#{user_id}"

    {countdown_ms, rate_limit} =
      case model do
        "gpt-3.5-turbo-0125" -> {:timer.hours(4), 5}
        "gpt-4o" -> {:timer.hours(22), 2}
      end

    case Hammer.check_rate(id, countdown_ms, rate_limit) do
      {:allow, _count} ->
        fun.()

      {:deny, _limit} ->
        {:ok, bucket} = Hammer.inspect_bucket(id, countdown_ms, rate_limit)
        time_left_ms = elem(bucket, 2)

        {:error, :rate_limit, time_left_ms}
    end
  end
end
