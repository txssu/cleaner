defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  command("ping")

  middleware(ExGram.Middleware.IgnoreUsername)

  def handle({:command, :ping, _msg}, context) do
    answer(context, "pong")
  end

  def handle({:message, %{dice: %{emoji: "🎰", value: value}} = message}, context) do
    if winning_dice?(value) do
      context
    else
      delete(context, message)
    end
  end

  def handle(_event, context), do: context

  defp winning_dice?(dice_value) do
    <<right::binary-size(2), center::binary-size(2), left::binary-size(2)>> =
      (dice_value - 1)
      |> Integer.to_string(2)
      |> String.pad_leading(6, "0")

    left == center and center == right
  end
end
