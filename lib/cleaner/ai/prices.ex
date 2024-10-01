defmodule Cleaner.AI.Prices do
  @moduledoc false
  def calculate(model, input_tokens, output_tokens)

  def calculate("gpt-4o-2024-08-06", input_tokens, output_tokens) do
    input_tokens * rubles_to_units(0.72) + output_tokens * rubles_to_units(2.88)
  end

  def calculate("gpt-4o-mini", input_tokens, output_tokens) do
    input_tokens * rubles_to_units(0.0432) + output_tokens * rubles_to_units(0.1728)
  end

  @spec units_to_rubles(integer()) :: float()
  def units_to_rubles(units) do
    units / 100_000
  end

  @spec rubles_to_units(float()) :: integer()
  def rubles_to_units(units) do
    round(units * 100)
  end
end
