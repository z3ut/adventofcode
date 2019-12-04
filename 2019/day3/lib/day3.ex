defmodule Point do
  defstruct [:x, :y]
end

defmodule Segment do
  defstruct [:p1, :p2]
end

defmodule Geometry do
  def get_segments_intersection(s1, s2) do
    a1 = s1.p2.y - s1.p1.y
    b1 = s1.p1.x - s1.p2.x
    c1 = a1 * s1.p1.x + b1 * s1.p1.y

    a2 = s2.p2.y - s2.p1.y
    b2 = s2.p1.x - s2.p2.x
    c2 = a2 * s2.p1.x + b2 * s2.p1.y

    delta = a1 * b2 - a2 * b1

    if delta == 0 do
      {false, nil}
    else
      intersection = %Point{ x: (b2 * c1 - b1 * c2) / delta, y: (a1 * c2 - a2 * c1) / delta}

      if point_on_segment?(intersection, s1) and point_on_segment?(intersection, s2) do
        {true, intersection}
      else
        {false, nil}
      end
    end
  end

  def point_on_segment?(point, segment) do
    min(segment.p1.x, segment.p2.x) <= point.x and
      point.x <= max(segment.p1.x, segment.p2.x) and
      min(segment.p1.y, segment.p2.y) <= point.y and
      point.y <= max(segment.p1.y, segment.p2.y)
  end

  def get_intersections(segments1, segments2) do
    for s1 <- segments1, s2 <- segments2 do [s1, s2] end
    |> Enum.map(fn [s1, s2] -> Geometry.get_segments_intersection(s1, s2) end)
    |> Enum.filter(fn { intersected?, p } -> intersected? and (p.x != 0 or p.y != 0) end)
    |> Enum.map(fn { _, p } -> p end)
  end

  def get_intersections_steps(intersections, segments) do
    intersections
    |> Enum.map(fn point -> Geometry.get_intersection_steps(intersection, segments) end)
  end

  def get_intersection_steps(point, segments) do
    segments
    |> Enum.reduce_while(0, fn segment, current_steps ->
      if Geometry.point_on_segment?(point, segment) do
        passed_steps = abs(segment.p1.x - point.x) + abs(segment.p1.y - point.y)
        {:halt, current_steps + passed_steps }
      else
        {:cont, current_steps + Geometry.get_segment_steps(segment) }
      end
    end)
  end

  def get_segment_steps(segment) do
    abs(segment.p1.x - segment.p2.x) + abs(segment.p1.y - segment.p2.y)
  end
end

defmodule Wires do
  def get_wires_segments(filename) do
    File.read!(filename)
    |> String.split(["\n", "\r", "\r\n"])
    |> Enum.map(&Wires.parse_wire_line/1)
  end

  def parse_wire_line(line) do
    line
    |> String.split(",")
    |> Enum.reduce({ %Point{x: 0, y: 0}, [] }, fn code, { current_point, segments } ->
      { segment, ending_point } = create_segment(current_point, code)
      { ending_point, [ segment | segments ] }
    end)
    |> (fn { _, segments } -> segments end).()
    |> Enum.reverse
  end

  def create_segment(starting_point, code) do
    direction = String.at(code, 0)
    value = String.slice(code, 1..-1) |> (&String.to_integer/1).()
    ending_point = Wires.create_ending_point(starting_point, direction, value)
    segment = %Segment{ p1: starting_point, p2: ending_point }
    { segment, ending_point }
  end

  def create_ending_point(starting_point, direction, value) do
    case direction do
      "R" -> %Point{ x: starting_point.x + value, y: starting_point.y }
      "U" -> %Point{ x: starting_point.x, y: starting_point.y + value }
      "L" -> %Point{ x: starting_point.x - value, y: starting_point.y }
      "D" -> %Point{ x: starting_point.x, y: starting_point.y - value }
    end
  end
end

defmodule Day3 do
  def part1(filename) do
    apply(&Geometry.get_intersections/2, Wires.get_wires_segments(filename))
    |> Enum.map(fn p -> abs(p.x) + abs(p.y) end)
    |> Enum.min
  end

  def part2(filename) do
    [ segments1, segments2 ] = Wires.get_wires_segments(filename)
    intersections = Geometry.get_intersections(segments1, segments2)

    intersections1_steps = Geometry.get_intersections_steps(intersections, segments1)
    intersections2_steps = Geometry.get_intersections_steps(intersections, segments2)

    Enum.zip(intersections1_steps, intersections2_steps)
    |> Enum.map(fn { l1, l2 } -> l1 + l2 end)
    |> Enum.min
  end
end
