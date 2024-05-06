defmodule Cleaner.AI.OpenAIClient do
  @moduledoc false

  use Pathex
  use Tesla, only: [:post], docs: false

  plug(Tesla.Middleware.BaseUrl, api_url())
  plug(Tesla.Middleware.Headers, [{"authorization", api_key()}])
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Timeout, timeout: 10_000)

  @type message :: %{role: String.t(), content: String.t()}

  @spec completion([message()]) :: {:error, any()} | {:ok, any()}
  def completion(messages) do
    body = %{
      model: "gpt-3.5-turbo-0125",
      messages: messages
    }

    with {:ok, %{body: body}} <- post("/v1/chat/completions", body) do
      content = Pathex.view!(body, path("choices" / 0 / "message" / "content"))

      {:ok, content}
    end
  end

  @spec message(String.t(), String.t()) :: message()
  def message(role \\ "user", content) do
    %{role: role, content: content}
  end

  defp api_url do
    :cleaner
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(:api_url)
  end

  defp api_key do
    :cleaner
    |> Application.get_env(__MODULE__)
    |> Keyword.fetch!(:api_key)
  end
end
