defmodule Point do
  defstruct [:x, :y]
end

defmodule OutputResult do
  defstruct [:exit?, :elem, :code, :pointer, :input, :relative_base]
end

defmodule ComputerState do
  defstruct [:code, :pointer, :input]
end

defmodule IntcodeComputer do
  def execute_instruction({code, pointer, input, relative_base, loop?}) do
    instruction = Map.get(code, pointer)
    digits = Integer.digits(instruction)
    modes = List.duplicate(0, 4) ++ digits |> Enum.slice(-5, 3) |> Enum.reverse
    opcode = digits |> Enum.take(-2) |> Integer.undigits
    case opcode do
      1 ->
        execute_four_parameters_instruction(code, pointer, modes, input, relative_base, loop?, &(&1 + &2))
        |> execute_instruction
      2 ->
        execute_four_parameters_instruction(code, pointer, modes, input, relative_base, loop?, &(&1 * &2))
        |> execute_instruction
      3 ->
        execute_input(code, pointer, modes, input, relative_base, loop?) |> execute_instruction
      4 ->
        {code, pointer, input, relative_base, elem} = execute_output(code, pointer, modes, input, relative_base, loop?)
        if loop? do
          %OutputResult{exit?: false, elem: elem, code: code, pointer: pointer, input: input, relative_base: relative_base}
        else 
          execute_instruction({code, pointer, input, relative_base, loop?})
        end
      5 ->
        execute_jump_if(code, pointer, modes, input, relative_base, loop?, &(&1 != 0)) |> execute_instruction
      6 ->
        execute_jump_if(code, pointer, modes, input, relative_base, loop?, &(&1 == 0)) |> execute_instruction
      7 ->
        execute_store_if(code, pointer, modes, input, relative_base, loop?, &(&1 < &2)) |> execute_instruction
      8 ->
        execute_store_if(code, pointer, modes, input, relative_base, loop?, &(&1 == &2)) |> execute_instruction
      9 ->
        execute_adjust_relative_base(code, pointer, modes, input, relative_base, loop?) |> execute_instruction
      99 ->
        %OutputResult{exit?: true, elem: input, code: code, pointer: pointer, input: input, relative_base: relative_base}
    end
  end

  defp execute_input(code, pointer, modes, input, relative_base, loop?) do
    result_pointer = get_literal_param(code, pointer + 1, Enum.at(modes, 0), relative_base)
    code = Map.put(code, result_pointer, input)
    {code, pointer + 2, input, relative_base, loop?}
  end

  defp execute_output(code, pointer, modes, input, relative_base, loop?) do
    {elem} = get_params(code, pointer, modes, relative_base, 1)
    {code, pointer + 2, input, relative_base, elem}
  end

  defp execute_jump_if(code, pointer, modes, input, relative_base, loop?, fun) do
    {elem, new_pointer} = get_params(code, pointer, modes, relative_base, 2)
    {code, (if fun.(elem) do new_pointer else pointer + 3 end), input, relative_base, loop?}
  end

  defp execute_store_if(code, pointer, modes, input, relative_base, loop?, fun) do
    {first_elem, second_elem} = get_params(code, pointer, modes, relative_base, 2)
    result_pointer = get_literal_param(code, pointer + 3, Enum.at(modes, 2), relative_base)
    value = if fun.(first_elem, second_elem) do 1 else 0 end
    code = Map.put(code, result_pointer, value)
    {code, pointer + 4, input, relative_base, loop?}
  end

  defp execute_four_parameters_instruction(code, pointer, modes, input, relative_base, loop?, fun) do
    {first_elem, second_elem} = get_params(code, pointer, modes, relative_base, 2)
    result_pointer = get_literal_param(code, pointer + 3, Enum.at(modes, 2), relative_base)
    result = fun.(first_elem, second_elem)
    code = Map.put(code, result_pointer, result)
    {code, pointer + 4, input, relative_base, loop?}
  end

  defp execute_adjust_relative_base(code, pointer, modes, input, relative_base, loop?) do
    {adjust_value} = get_params(code, pointer, modes, relative_base, 1)
    {code, pointer + 2, input, relative_base + adjust_value, loop?}
  end

  defp get_params(code, pointer, modes, relative_base, count) do
    1..count |>
    Enum.map(fn n ->
      index_or_value = Map.get(code, pointer + n, 0)
      case Enum.at(modes, n - 1) do
        0 -> Map.get(code, index_or_value, 0)
        1 -> index_or_value
        2 -> Map.get(code, relative_base + index_or_value, 0)
      end
    end)
    |> List.to_tuple
  end

  defp get_literal_param(code, pointer, mode, relative_base) do
    result_pointer = Map.get(code, pointer)
    if mode == 2 do
      relative_base + result_pointer
    else
      result_pointer
    end
  end
end

defmodule IntcodeSources do
  def get_code(filename) do
    File.read!(filename)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new
  end
end


defmodule Day11 do
  def part1(filename) do
    code = IntcodeSources.get_code(filename)
    execute_painting(code, 0, 0, %{%Point{x: 0, y: 0} => 0}, 0, 0, 0)
    |> Enum.count
  end

  def part2(filename) do
    code = IntcodeSources.get_code(filename)
    field = execute_painting(code, 0, 0, %{%Point{x: 0, y: 0} => 1}, 0, 0, 0)
    
    all_x = Map.keys(field) |> Enum.map(fn p -> p.x end)
    all_y = Map.keys(field) |> Enum.map(fn p -> p.y end)

    min_x = Enum.min(all_x)
    min_y = Enum.min(all_y)

    max_x = Enum.max(all_x)
    max_y = Enum.max(all_x)

    registration_identifier =
    for y <- max_y..min_y do
      for x <- min_x..max_x do
        if Map.get(field, %Point{x: x, y: y}, 0) == 0, do: " ", else: "#"
      end
    end
    |> Enum.join("\n")

    IO.puts registration_identifier
  end

  def execute_painting(code, pointer, relative_base, field, cur_x, cur_y, cur_dir) do
    input = Map.get(field, %Point{x: cur_x, y: cur_y}, 0)
    res1 = IntcodeComputer.execute_instruction(
      {code, pointer, input, relative_base, true})
    if res1.exit? do
      field
    else
      res2 = IntcodeComputer.execute_instruction(
        {res1.code, res1.pointer, input, res1.relative_base, true})
      new_field = Map.put(field, %Point{x: cur_x, y: cur_y}, res1.elem)
      new_dir = rem(cur_dir + (if res2.elem == 0, do: -90, else: 90) + 360, 360)
      new_x = case new_dir do
        90 -> cur_x + 1
        270 -> cur_x - 1
        _ -> cur_x
      end
      new_y = case new_dir do
        0 -> cur_y + 1
        180 -> cur_y - 1
        _ -> cur_y
      end
      execute_painting(res2.code, res2.pointer, res2.relative_base, new_field, new_x, new_y, new_dir)
    end
  end
end
