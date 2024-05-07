defmodule Cleaner.Commands.AskZhenegi do
  @moduledoc false

  def call("") do
    "Используй: /ask_zhenegi текст-вопроса"
  end

  def call(text) do
    "@zhenegi спроси это позязя /ask #{text}"
  end
end
