defmodule Cleaner.Bot do
  @moduledoc false
  use ExGram.Bot, name: __MODULE__, setup_commands: true

  alias Cleaner.DiceRemover

  command("ping")

  middleware(ExGram.Middleware.IgnoreUsername)

  @spec handle(ExGram.Dispatcher.parsed_message(), ExGram.Cnt.t()) :: ExGram.Cnt.t()
  def handle({:command, :ping, _msg}, context) do
    answer(context, "pong")
  end

  def handle({:message, %{dice: %{emoji: "🎰", value: value}} = message}, context) do
    unless winning_dice?(value) do
      %{chat_id: message.chat.id, message_id: message.message_id}
      |> DiceRemover.new(schedule_in: 3)
      |> Oban.insert()
    end

    context
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
