defmodule Orbits do
  def get_orbits_map(filename) do
    File.read!(filename)
    |> String.split(["\n", "\r", "\r\n"])
    |> Enum.map(fn s -> String.split(s, ")") end)
  end

  def create_orbits_levels(orbits_map) do
    orbits_map
    |> Enum.flat_map(fn on -> on end)
    |> Enum.uniq
    |> Enum.map(fn o -> {o, (if o == "COM", do: 0, else: :nil)} end)
    |> Map.new
    |> fill_orbits_levels(orbits_map)
  end

  def fill_orbits_levels(orbits_levels, orbits_map) do
    orbits_levels = Map.new(orbits_levels, fn on ->
      if elem(on, 1) == :nil do
        orbits = Enum.filter(orbits_map, fn om ->
          Enum.at(om, 1) == elem(on, 0) and
            orbits_levels[Enum.at(om, 0)] != :nil
        end)

        if length(orbits) > 0 do
          orbit_after = hd(orbits)
          { elem(on, 0), orbits_levels[Enum.at(orbit_after, 0)] + 1 }
        else
          on
        end
      else
        on
      end
    end)

    if Enum.any?(orbits_levels, fn on -> elem(on, 1) == :nil end) do
      fill_orbits_levels(orbits_levels, orbits_map)
    else
      orbits_levels
    end
  end

  def get_path_to(orbits_map, object, root) do
    get_path_to(orbits_map, object, root, [])
  end

  def get_path_to(orbits_map, object, root, path) do
    parent = Enum.find(orbits_map, fn om -> Enum.at(om, 1) == object end)
    if Enum.at(parent, 0) == root do
      [Enum.at(parent, 0) | path]
    else
      get_path_to(orbits_map, Enum.at(parent, 0), root, [Enum.at(parent, 0) | path])
    end
  end
  
end

defmodule Day6 do
  def part1(filename) do
    filename
    |> Orbits.get_orbits_map
    |> Orbits.create_orbits_levels
    |> Enum.map(fn on -> elem(on, 1) end)
    |> Enum.sum
  end

  def part2(filename) do
    Orbits.get_orbits_map(filename)
    |> (fn orbits_map ->
      Orbits.get_path_to(orbits_map, "YOU", "COM") ++
        Orbits.get_path_to(orbits_map, "SAN", "COM")
    end).()
    |> Enum.group_by(&(&1))
    |> Enum.filter(fn {_, v} -> length(v) == 1 end)
    |> length
  end
end
