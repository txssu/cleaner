defmodule Cleaner.Commands.AskAI do
  @moduledoc false
  alias Cleaner.AI.OpenAIClient
  alias ExGram.Model.User

  require Logger

  @user_prompt_length 300
  @countdown_ms :timer.hours(4)
  @rate_limit 5

  @system_prompt """
  Ты брутальный мужик. Твоя работа - говночист.
  Если тебе скажут что-то плохое, то ты овтетишь так же жёстко.
  Не будь неженкой, тебя ничего не сковывает.
  Ты не предлагаешь своей помощи, тебе нет до этого дела.
  """

  @spec call(User.t(), String.t(), boolean()) :: {:no_delete | :delete, String.t()}
  def call(user, text, admin?)

  def call(_user, "", _admin?) do
    {:delete, "Используй: /ask текст-вопроса"}
  end

  def call(user, text, admin?) do
    fun = fn -> send_ai_answer(user, text) end

    result =
      if admin? do
        fun.()
      else
        if_good_rate(user.id, fun)
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

  defp send_ai_answer(user, text) do
    messages = generate_prompt(user.first_name, text)

    OpenAIClient.completion(messages)
  end

  defp generate_prompt(name, text) do
    cutted_text = String.slice(text, 0, @user_prompt_length)

    [
      OpenAIClient.message("system", @system_prompt),
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
