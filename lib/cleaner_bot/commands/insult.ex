defmodule CleanerBot.Commands.Insult do
  @moduledoc false

  @spec call() :: String.t()
  def call do
    InsultGenerator.generate_insult()
  end
end
