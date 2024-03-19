defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  command("start")

  middleware(ExGram.Middleware.IgnoreUsername)

  def handle({:command, :start, _msg}, context) do
    answer(context, "Даров!")
  end

  def handle({:text, text, _msg}, context) do
    answer(context, text)
  end
end
