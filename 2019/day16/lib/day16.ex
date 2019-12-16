defmodule Day16 do
  def part1(filename) do
    File.read!(filename)
    |> String.to_integer
    |> Integer.digits
    |> execute_phases([0, 1, 0, -1], 0, 100)
    |> Enum.take(8)
    |> Integer.undigits
  end

  def get_pattern_value(pattern, group_size, index) do
    Enum.at(pattern, rem(div(index + 1, group_size), length(pattern)))
  end

  def execute_phases(digits, pattern, current_phase, max_phase) do
    if current_phase == max_phase do
      digits
    else
      new_digits =
      0..length(digits)
      |> Enum.map(fn index ->
        digits
        |> Enum.with_index
        |> Enum.map(fn {digit, digit_index} ->
          digit * get_pattern_value(pattern, index + 1, digit_index)
        end)
        |> Enum.sum
        |> abs
        |> Integer.digits
        |> Enum.at(-1)
      end)

      execute_phases(new_digits, pattern, current_phase + 1, max_phase)
    end
  end
end
