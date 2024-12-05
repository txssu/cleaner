defmodule CleanerBot.SaveEventMiddleware do
  @moduledoc false
  use ExGram.Middleware
  use Pathex

  @spec call(ExGram.Cnt.t(), any()) :: ExGram.Cnt.t()
  def call(%{update: update} = context, _options) do
    update
    |> minify_data()
    |> Cleaner.Update.save()

    context
  end

  defp minify_data(data) when is_struct(data) do
    data
    |> Map.from_struct()
    |> minify_data()
  end

  defp minify_data(map) when is_map(map) do
    map
    |> Map.new(fn {key, value} -> {key, minify_data(value)} end)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)

    for {key, value} <- map,
        not is_nil(value),
        minified_value = minify_data(value),
        into: %{},
        do: {key, minify_data(minified_value)}
  end

  defp minify_data(value) do
    value
  end
end
