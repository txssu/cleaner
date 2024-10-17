defmodule CleanerBot.Commands.Kolovrat do
  @moduledoc false
  alias Clenaer.KolovratGenerator

  @spec call(String.t()) :: String.t()
  def call(text) do
    line = text |> String.replace("\n", " ") |> String.trim()

    """
    ```
    #{KolovratGenerator.word_to_kolovrat(line)}
    ```
    """
  end
end
