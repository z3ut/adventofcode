defmodule Planet do
  defstruct [:x, :y, :z, :vx, :vy, :vz] 
end

# https://rosettacode.org/wiki/Least_common_multiple#Elixir
defmodule RC do
  def gcd(a,0), do: abs(a)
  def gcd(a,b), do: gcd(b, rem(a,b))
 
  def lcm(a,b), do: div(abs(a*b), gcd(a,b))
end

defmodule PlanetProvider do
  def get_planets() do
    [
      %Planet{x: 3, y: 2, z: -6, vx: 0, vy: 0, vz: 0},
      %Planet{x: -13, y: 18, z: 10, vx: 0, vy: 0, vz: 0},
      %Planet{x: -8, y: -1, z: 13, vx: 0, vy: 0, vz: 0},
      %Planet{x: 5, y: 10, z: 4, vx: 0, vy: 0, vz: 0}
    ]
  end
end

defmodule Day12 do

  def part1() do
    planets = PlanetProvider.get_planets()
    calculate_total_energy_at_step(planets, 0, 1000)
  end

  def part2() do
    planets = PlanetProvider.get_planets()
    calculate_planets_cycle_for_keys(planets, [
      fn p -> [p.x, p.vx] end,
      fn p -> [p.y, p.vy] end,
      fn p -> [p.z, p.vz] end
    ])
  end

  def calculate_total_energy_at_step(planets, current_step, max_step) do
    if current_step == max_step do
      Enum.reduce(planets, 0, fn p, total_energy ->
        total_energy + (abs(p.x) + abs(p.y) + abs(p.z)) * (abs(p.vx) + abs(p.vy) + abs(p.vz))
      end)
    else
      calculate_total_energy_at_step(simulate_step(planets), current_step + 1, max_step)
    end
  end

  def calculate_planets_cycle_for_keys(planets, planet_key_fns) do
    tracking_cycles = Enum.map(planet_key_fns, fn kfn -> {kfn, -1, %{}} end)
    calculate_planets_cycle_for_keys(planets, 0, tracking_cycles)
  end

  def calculate_planets_cycle_for_keys(planets, step, tracking_cycles) do
    updated_planets = simulate_step(planets)

    new_tracking_cycles =
    tracking_cycles
    |> Enum.map(fn {planet_key_fn, key_step, cycles} ->
      if key_step == -1 do
        cycle_key =
        updated_planets
        |> Enum.map(planet_key_fn)
        |> List.flatten

        if Map.has_key?(cycles, cycle_key) do
          {planet_key_fn, step, cycles}
        else
          {planet_key_fn, key_step, Map.put(cycles, cycle_key, step)}
        end  
      else
        {planet_key_fn, key_step, cycles}
      end
    end)

    if Enum.all?(tracking_cycles, fn {_, key_step, _} -> key_step > 0 end) do
      tracking_cycles
      |> Enum.map(fn {_, key_step, _ }-> key_step end)
      |> Enum.reduce(&RC.lcm/2)
    else
      calculate_planets_cycle_for_keys(updated_planets, step + 1, new_tracking_cycles)
    end
  end

  def get_new_velocity(velocity, coord_1, coord_2) do
    cond do
      coord_1 < coord_2 -> velocity + 1
      coord_1 == coord_2 -> velocity
      coord_1 > coord_2 -> velocity - 1
    end
  end

  def simulate_step(planets) do
    planets
    |> Enum.map(fn current_planet ->
      planets
      |> Enum.filter(fn p -> p != current_planet end)
      |> Enum.reduce(current_planet, fn p, acc ->
        new_vx = get_new_velocity(acc.vx, acc.x, p.x)
        new_vy = get_new_velocity(acc.vy, acc.y, p.y)
        new_vz = get_new_velocity(acc.vz, acc.z, p.z)

        %Planet{x: acc.x, y: acc.y, z: acc.z,
          vx: new_vx, vy: new_vy, vz: new_vz}
      end)

    end)
    |> Enum.map(fn p ->
      %Planet{x: p.x + p.vx, y: p.y + p.vy, z: p.z + p.vz,
        vx: p.vx, vy: p.vy, vz: p.vz}
    end)
  end
end
