defmodule Clenaer.KolovratGenerator do
  @moduledoc false

  @spec word_to_kolovrat(String.t()) :: String.t()
  def word_to_kolovrat(word) do
    word = maybe_append_length(word)
    width = String.length(word)

    width
    |> kolovrat_template()
    |> add_word_to_template(word)
    |> to_string(width)
  end

  defp maybe_append_length(word) do
    case String.length(word) do
      1 -> word <> word <> word
      n when n in 2..3 -> word <> word
      _greater -> word
    end
  end

  defp kolovrat_template(width) do
    size = width - 1

    wing_right =
      Enum.map(size..0, fn x -> {x, 0} end) ++
        Enum.map(0..size, fn y -> {size, y} end)

    wing_down = Enum.map(wing_right, fn {x, y} -> {-y, x} end)
    wing_left = Enum.map(wing_right, fn {x, y} -> {-x, -y} end)
    wing_up = Enum.map(wing_right, fn {x, y} -> {y, -x} end)

    kolovrat = wing_right ++ wing_down ++ wing_left ++ wing_up

    Enum.map(kolovrat, fn {x, y} -> {x + size, y + size} end)
  end

  defp add_word_to_template(template, word) do
    chars = word |> String.graphemes() |> Stream.cycle()

    Enum.zip(template, chars)
  end

  defp to_string(template, size) do
    (size * 2)
    |> matrix()
    |> Enum.map(fn coord ->
      Enum.find_value(template, " ", fn {template_coord, char} ->
        template_coord == coord && char
      end)
    end)
    |> Enum.chunk_every(size * 2)
    |> Enum.map_join("\n", &Enum.join/1)
  end

  defp matrix(size) do
    for y <- 0..(size - 1), x <- 0..(size - 1) do
      {x, y}
    end
  end
end
