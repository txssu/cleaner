defmodule Cleaner.Commands.DeleteLosingDice do
  @moduledoc false
  alias Cleaner.ChatConfig
  alias Cleaner.DelayMessageRemover

  @winning_values %{
    "🎯" => 6,
    "🎳" => 6,
    "🎲" => 6,
    "⚽" => 5,
    "🏀" => 5
  }

  @spec call(ChatConfig.t(), ExGram.Model.Message.t(), ExGram.Model.Dice.t()) :: :ok
  def call(chat_config, message, dice) do
    unless winning_dice?(dice) do
      DelayMessageRemover.schedule_delete_message(
        message.chat.id,
        message.message_id,
        chat_config.delete_delay_in_seconds
      )
    end

    :ok
  end

  defp winning_dice?(%{emoji: "🎰", value: dice_value}) do
    <<right::binary-size(2), center::binary-size(2), left::binary-size(2)>> =
      (dice_value - 1)
      |> Integer.to_string(2)
      |> String.pad_leading(6, "0")

    left == center and center == right
  end

  defp winning_dice?(%{emoji: emoji, value: dice_value}) do
    %{^emoji => winning_value} = @winning_values
    winning_value == dice_value
  end
end
