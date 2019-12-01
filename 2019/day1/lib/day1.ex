defmodule FuelRequrements do
  def calculate_fuel_for_mass (mass) do
    div(mass, 3) - 2 |> max(0)
  end

  def calculate_fuel_for_module (mass) do
    module_fuel = calculate_fuel_for_mass(mass)
    if module_fuel == 0 do
      module_fuel
    else
      module_fuel + calculate_fuel_for_module(module_fuel)
    end
  end
end

defmodule SpacecraftSpecs do
  def get_module_masses(input) do
    File.read!(input)
    |> String.split
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Day1 do
  def part1(input) do
    SpacecraftSpecs.get_module_masses(input)
    |> Enum.map(&FuelRequrements.calculate_fuel_for_mass/1)
    |> Enum.sum
  end

  def part2(input) do
    SpacecraftSpecs.get_module_masses(input)
    |> Enum.map(&FuelRequrements.calculate_fuel_for_module/1)
    |> Enum.sum
  end
end
