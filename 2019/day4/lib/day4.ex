defmodule Day4 do
  def part1 do
    part1_digits()
    |> Enum.count
  end

  def part2 do
    part1_digits()
    |> Enum.filter(fn d ->
      Enum.chunk_by(d, &(&1))
      |> Enum.any?(fn chunks -> length(chunks) == 2 end) end)
    |> Enum.count
  end

  defp part1_digits() do
    138307..654504
    |> Enum.map(&Integer.digits/1)
    |> Enum.filter(fn d -> Enum.sort(d) == d and Enum.uniq(d) != d end)
  end
end
