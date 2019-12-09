defmodule OutputResult do
  defstruct [:exit?, :elem, :code, :pointer, :input]
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
          %OutputResult{exit?: false, elem: elem, code: code, pointer: pointer, input: input}
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
        %OutputResult{exit?: true, elem: hd(input), code: code, pointer: pointer, input: input}
    end
  end

  defp execute_input(code, pointer, modes, input, relative_base, loop?) do
    result_pointer = get_literal_param(code, pointer + 1, Enum.at(modes, 0), relative_base)
    [input_value | remaining_input] = input
    code = Map.put(code, result_pointer, input_value)
    {code, pointer + 2, remaining_input, relative_base, loop?}
  end

  defp execute_output(code, pointer, modes, input, relative_base, loop?) do
    {elem} = get_params(code, pointer, modes, relative_base, 1)
    {code, pointer + 2, (if loop?, do: input, else: input ++ [elem]), relative_base, elem}
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

defmodule Day9 do
  def part1(filename) do
    execute_intcode(filename, [1])
  end

  def part2(filename) do
    execute_intcode(filename, [2])
  end

  defp execute_intcode(filename, input) do
    code = IntcodeSources.get_code(filename)
    IntcodeComputer.execute_instruction({code, 0, input, 0, false})
    |> Map.get(:input)
    |> hd
  end
end
