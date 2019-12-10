defmodule Point do
  defstruct [:x, :y]
end

defmodule PointRelativePosition do
  defstruct [:x, :y, :angle, :distance]
end

defmodule Geometry do
  def point_on_line?(p1, p2, p) do
    abs(get_distance(p1, p) + get_distance(p2, p) - get_distance(p1, p2)) < 0.000005
  end

  def get_distance(p1, p2) do
    :math.sqrt(:math.pow(p1.x - p2.x, 2) + :math.pow(p1.y - p2.y, 2))
  end

  def get_point_angle(center_point, relative_point) do
    delta_x = relative_point.x - center_point.x
    delta_y = relative_point.y - center_point.y
    atan = :math.atan2(delta_x, -delta_y)
    if atan < 0, do: atan + :math.pi * 2, else: atan
  end
end

defmodule MonitoringStation do
  def get_asteroids(filename) do
    File.read!(filename)
    |> String.split(["\n", "\r", "\r\n"])
    |> Enum.map(&String.graphemes/1)
    |> Enum.map_reduce(0, fn line, row ->
      Enum.map_reduce(line, 0, fn char, column ->
        {(if char == "#", do: column, else: -1), column + 1}
      end)
      |> elem(0)
      |> Enum.filter(&(&1 >= 0))
      |> Enum.map(fn column -> %Point{x: column, y: row} end)
      |> (fn ast -> {ast, row + 1} end).()
    end)
    |> elem(0)
    |> List.flatten
  end
end

defmodule Day10 do
  def part1(filename) do
    filename
    |> MonitoringStation.get_asteroids
    |> get_observatory_point
    |> elem(1)
  end

  def part2(filename) do
    asteroids = MonitoringStation.get_asteroids(filename)
    {observatory, _} = get_observatory_point(asteroids)

    asteroids
    |> Enum.filter(fn a -> a.x != observatory.x or a.y != observatory.y end)
    |> Enum.map(fn a ->
      angle = Geometry.get_point_angle(observatory, a)
      distance = Geometry.get_distance(a, %Point{x: observatory.x, y: observatory.y})
      %PointRelativePosition{x: a.x, y: a.y, angle: angle, distance: distance}
    end)
    |> Enum.group_by(fn a -> a.angle end, fn a -> a end)
    |> Enum.sort_by(fn a -> elem(a, 0) end)
    |> Enum.map(fn ast -> Enum.sort_by(elem(ast, 1), fn a -> a.distance end) end)
    |> get_vaporized_asteroid(0, 0, 199)
    |> (fn p -> p.x * 100 + p.y end).()
  end

  def get_vaporized_asteroid(asteroids_by_angle, current_angle_group, step, n) do
    [ast | rest] = Enum.at(asteroids_by_angle, current_angle_group)
    if step == n do
      ast
    else
      if length(rest) > 0 do
        new_asteroids = List.replace_at(asteroids_by_angle, current_angle_group, rest)
        get_vaporized_asteroid(new_asteroids,
          rem(current_angle_group + 1, length(new_asteroids)), step + 1, n)
      else
        new_asteroids = List.delete_at(asteroids_by_angle, current_angle_group)
        get_vaporized_asteroid(new_asteroids,
          rem(current_angle_group, length(new_asteroids)), step + 1, n)
      end
    end
  end

  def get_observatory_point(asteroids) do
    Enum.map(asteroids, fn station_candidate ->
      other_asteroids = Enum.filter(asteroids, fn a ->
        !Map.equal?(a, station_candidate) end)

      visible_asteroids = Enum.count(other_asteroids, fn possible_visible_asteroid ->
        Enum.filter(other_asteroids, fn a -> !Map.equal?(a, possible_visible_asteroid) end)
        |> Enum.all?(fn a ->
          !Geometry.point_on_line?(station_candidate, possible_visible_asteroid, a)
        end)
      end)

      {%Point{x: station_candidate.x, y: station_candidate.y}, visible_asteroids}
    end)
    |> Enum.max_by(fn {_, count} -> count end)
  end
end
