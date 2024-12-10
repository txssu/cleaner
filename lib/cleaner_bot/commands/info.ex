defmodule CleanerBot.Commands.Info do
  @moduledoc false
  use Pathex

  @spec call(ExGram.Cnt.t()) :: String.t()
  def call(context) do
    context
    |> get_chat_id()
    |> maybe_append_user_info(context)
  end

  defp get_chat_id(context) do
    chat_id = Pathex.view!(context, path(:update / :message / :chat / :id, :map))

    "Chat ID: #{chat_id}"
  end

  defp maybe_append_user_info(text, context) do
    user_path = path(:update / :message / :reply_to_message / :from, :map)

    case Pathex.view(context, user_path) do
      {:ok, user} ->
        user_id = user.id
        first_name = user.first_name
        text <> "\nUser ID: #{user_id}\nFirst name: #{first_name}"

      :error ->
        text
    end
  end
end
