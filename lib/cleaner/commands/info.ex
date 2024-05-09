defmodule Cleaner.Commands.Info do
  @moduledoc false
  use Pathex

  @spec call(ExGram.Cnt.t()) :: String.t()
  def call(context) do
    context
    |> get_chat_id()
    |> maybe_append_user_id(context)
  end

  defp get_chat_id(context) do
    chat_id = Pathex.view!(context, path(:update / :message / :chat / :id, :map))

    "Chat ID: #{chat_id}"
  end

  defp maybe_append_user_id(text, context) do
    case Pathex.view(context, path(:update / :message / :reply_to_message / :from / :id, :map)) do
      {:ok, user_id} ->
        text <> "\nUser ID: #{user_id}"

      :error ->
        text
    end
  end
end
