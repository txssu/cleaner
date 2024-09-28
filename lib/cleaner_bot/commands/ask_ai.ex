defmodule CleanerBot.Commands.AskAI do
  @moduledoc false
  alias Cleaner.AI.OpenAIClient
  alias CleanerBot.Commands.AskAI.Params

  require Logger

  @user_prompt_length 300
  @countdown_ms :timer.hours(3)
  @rate_limit 8

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

  @spec call(Params.t()) :: {:no_delete | :delete, String.t()}
  def call(params)

  def call(%Params{text: ""}) do
    {:delete, "Используй: /ask текст-вопроса"}
  end

  def call(%Params{} = params) do
    fun = fn -> send_ai_answer(params.user, params.text, params.prompt, []) end

    result =
      if params.admin? do
        fun.()
      else
        if_good_rate(params.user.id, fun)
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

  defp send_ai_answer(user, text, prompt, options) do
    messages = generate_prompt(user.first_name, text, prompt)

    OpenAIClient.completion(messages, options)
  end

  defp generate_prompt(name, text, prompt) do
    cutted_text = String.slice(text, 0, @user_prompt_length)

    [
      OpenAIClient.message("system", prompt || @default_system_prompt),
      OpenAIClient.message("#{name}: #{cutted_text}")
    ]
  end

  defp if_good_rate(user_id, fun) do
    id = "ask_ai:#{user_id}"

    case Hammer.check_rate(id, @countdown_ms, @rate_limit) do
      {:allow, _count} ->
        fun.()

      {:deny, _limit} ->
        {:ok, bucket} = Hammer.inspect_bucket(id, @countdown_ms, @rate_limit)
        time_left_ms = elem(bucket, 2)

        {:error, :rate_limit, time_left_ms}
    end
  end
end
