defmodule CleanerBot.Commands.AskAI do
  @moduledoc false
  alias Cleaner.AI
  alias Cleaner.User.SpendedMoney
  alias CleanerBot.Commands.AskAI.Params

  require Logger

  @countdown_ms :timer.hours(3)
  @rate_limit 8

  @spec call(Params.t()) :: {:no_delete, String.t(), function()} | {:delete, String.t()}
  def call(params)

  def call(%Params{text: ""}) do
    {:delete, "Используй: /ask текст-вопроса"}
  end

  def call(%Params{} = params) do
    with_result =
      with :ok <- validate_rate(params.user.id, params.admin?) do
        AI.completion(
          params.user.first_name,
          params.text,
          params.reply_to,
          {params.chat_id, params.reply_to.message_id},
          params.prompt
        )
      end

    handle_result(with_result, params)
  end

  defp handle_result(result, params)

  defp handle_result({:ok, message, price, send_callback}, params) do
    SpendedMoney.insert(params.internal_user, "gpt-4o-mini", price)
    {:no_delete, message, send_callback}
  end

  defp handle_result({:error, :rate_limit, time_left_ms}, _params) do
    time_left_hours = time_left_ms / 1000 / 60 / 60
    formatted_time_left = :erlang.float_to_binary(time_left_hours, [{:decimals, 2}, :compact])
    {:delete, "Отстань, я занят!!\n(достигнут лимит запросов, попробуй через #{formatted_time_left} ч.)"}
  end

  defp handle_result(error, _params) do
    Logger.error("Unhandled error: #{inspect(error)}")
    {:delete, "АШИПКАА!!!"}
  end

  defp validate_rate(user_id, admin?)

  defp validate_rate(_user_id, true), do: :ok

  defp validate_rate(user_id, false) do
    id = "ask_ai:#{user_id}"

    case Hammer.check_rate(id, @countdown_ms, @rate_limit) do
      {:allow, _count} ->
        :ok

      {:deny, _limit} ->
        {:ok, bucket} = Hammer.inspect_bucket(id, @countdown_ms, @rate_limit)
        time_left_ms = elem(bucket, 2)

        {:error, :rate_limit, time_left_ms}
    end
  end
end
