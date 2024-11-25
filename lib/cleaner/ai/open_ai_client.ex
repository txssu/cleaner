defmodule Cleaner.AI.OpenAIClient do
  @moduledoc false

  use Pathex
  use Tesla, only: [:post], docs: false

  alias Cleaner.AI.Prices

  plug(Tesla.Middleware.BaseUrl, api_url())
  plug(Tesla.Middleware.Headers, [{"authorization", api_key()}])
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Timeout, timeout: 30_000)

  @type message :: %{role: String.t(), content: String.t()}

  @spec completion([message()], Keyword.t()) :: {:error, any()} | {:ok, String.t(), number()}
  def completion(messages, options \\ []) do
    model = Keyword.get(options, :model, "gpt-4o-mini")

    body = %{
      model: model,
      messages: messages
    }

    with {:ok, %{body: body}} <- post("/v1/chat/completions", body),
         {:ok, content} <- fetch_from_body(body, path("choices" / 0 / "message" / "content")),
         {:ok, input_tokens} <- fetch_from_body(body, path("usage" / "prompt_tokens")),
         {:ok, output_tokens} <- fetch_from_body(body, path("usage" / "completion_tokens")) do
      price = Prices.calculate(model, input_tokens, output_tokens)

      {:ok, content, price}
    end
  end

  def fetch_from_body(body, data_path) do
    case Pathex.view(body, data_path) do
      {:ok, content} -> {:ok, content}
      :error -> {:error, :api_payload_error, body}
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
    token =
      :cleaner
      |> Application.get_env(__MODULE__)
      |> Keyword.fetch!(:api_key)

    "Bearer #{token}"
  end
end
