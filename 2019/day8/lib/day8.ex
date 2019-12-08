defmodule Day8 do
  def get_layers(filename) do
    File.read!(filename)
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(25 * 6)
  end

  def part1(filename) do
    filename
    |> get_layers
    |> Enum.map(fn layer ->
      Enum.reduce(layer, %{}, fn pixel, layer_stat ->
        Map.update(layer_stat, pixel, 1, &(&1 + 1))
      end)
    end)
    |> Enum.min_by(fn layer_stat -> layer_stat[0] end)
    |> (fn layer_stat -> layer_stat[1] * layer_stat[2] end).()
  end

  def part2(filename) do
    IO.puts filename
    |> get_layers
    |> Enum.zip
    |> Enum.map(fn pixel_set ->
      pixel_set
      |> Tuple.to_list
      |> Enum.find(fn p -> p != 2 end)
      |> (fn pixel -> if pixel == 0, do: " ", else: "*" end).()
    end)
    |> Enum.chunk_every(25)
    |> Enum.join("\n")
  end
end
