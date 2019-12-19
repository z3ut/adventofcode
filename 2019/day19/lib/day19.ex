defmodule OutputResult do
  defstruct [:exit?, :elem, :code, :pointer, :input, :relative_base]
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
    [elem | rest] = input
    code = Map.put(code, result_pointer, elem)
    {code, pointer + 2, rest, relative_base, loop?}
  end

  defp execute_output(code, pointer, modes, input, relative_base, _) do
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
  def get_code_normal_mode(filename) do
    get_code(filename)
  end

  def get_code_free_mode(filename) do
    code = get_code(filename)
    Map.put(code, 0, 2)
  end

  def get_code(filename) do
    File.read!(filename)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new
  end
end

defmodule Day19 do
  def part1(filename) do
    code = IntcodeSources.get_code_normal_mode(filename)
    for x <- 0..49, y <- 0..49 do
      {x, y}
    end
    |> Enum.filter(fn {x, y} -> affected?(code, x, y) end)
    |> Enum.count
  end

  def part2(filename) do
    code = IntcodeSources.get_code_normal_mode(filename)
    {x, y} = get_square_position(code, 0, 50, 100)
    x * 10000 + y
  end

  def get_square_position(code, x, y, size) do
    current_affected? = affected?(code, x, y)
    next_affected? = affected?(code, x + 1, y)
    cond do
      current_affected? and !next_affected? and
        affected?(code, x - (size - 1), y + (size - 1)) ->
        {x - (size - 1), y}
      current_affected? and !next_affected? ->
        get_square_position(code, x, y + 1, size)
      true ->
        get_square_position(code, x + 1, y, size)
    end
  end

  def affected?(code, x, y) do
    res = IntcodeComputer.execute_instruction(
      {code, 0, [x, y], 0, true})
    res.elem == 1
  end

  # if square could exists without touching right border
  def get_square_accurate_position(code, x, y, size, start_x) do
    current_affected? = affected?(code, x, y)
    previous_affected? = affected?(code, x - 1, y)
    cond do
      !current_affected? and !previous_affected? ->
        get_square_accurate_position(code, x + 1, y, size, x)
      current_affected? and affected?(code, x + (size - 1), y)
        and affected?(code, x, y + (size - 1)) ->
        {x, y}
      !current_affected? and previous_affected? == true ->
        get_square_accurate_position(code, start_x, y + 1, size, start_x)
      current_affected? ->
        get_square_accurate_position(code, x + 1, y, size, start_x)
    end
  end
end
