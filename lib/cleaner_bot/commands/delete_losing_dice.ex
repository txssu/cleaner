defmodule CleanerBot.Commands.DeleteLosingDice do
  @moduledoc false
  use Pathex

  alias Cleaner.ChatConfig
  alias CleanerBot.DelayMessageRemover

  @winning_values %{
    "🎯" => 6,
    "🎳" => 6,
    "🎲" => 6,
    "⚽" => 3,
    "🏀" => 4
  }

  @spec call(ChatConfig.t(), ExGram.Model.Message.t(), ExGram.Model.Dice.t()) :: :ok
  def call(chat_config, message, dice) do
    unless winning_dice?(dice) do
      chat_id = Pathex.view!(message, path(:chat / :id, :map))
      message_id = Pathex.view!(message, path(:message_id, :map))
      delay_in_seconds = Pathex.view!(chat_config, path(:delete_delay_in_seconds, :map))

      DelayMessageRemover.schedule_delete_message(chat_id, message_id, delay_in_seconds)
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
    dice_value >= winning_value
  end
end
