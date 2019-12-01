defmodule Day1Test do
  use ExUnit.Case

  doctest FuelRequrements

  test "fuel calculation for mass" do
    assert FuelRequrements.calculate_fuel_for_mass(12) == 2
    assert FuelRequrements.calculate_fuel_for_mass(14) == 2
    assert FuelRequrements.calculate_fuel_for_mass(1969) == 654
    assert FuelRequrements.calculate_fuel_for_mass(100756) == 33583
  end

  test "fuel calculation for module" do
    assert FuelRequrements.calculate_fuel_for_module(100756) == 50346
  end 
end
