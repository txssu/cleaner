defmodule CleanerBot.Commands.AskZhenegi do
  @moduledoc false

  @spec call(String.t()) :: String.t()
  def call("") do
    "Используй: /ask_zhenegi текст-вопроса"
  end

  def call(text) do
    "@zhеnеgi спроси это позязя /ask #{text}"
  end
end
