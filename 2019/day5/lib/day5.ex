defmodule IntcodeComputer do
  def execute_program(code, input) do
    {_, _, input} = execute_instruction({code, 0, input})
    input
  end

  defp execute_instruction({code, pointer, input}) do
    instruction = Enum.at(code, pointer)
    digits = Integer.digits(instruction)
    modes = List.duplicate(0, 4) ++ digits |> Enum.slice(-5, 3) |> Enum.reverse
    opcode = digits |> Enum.take(-2) |> Integer.undigits
    case opcode do
      1 ->
        execute_four_parameters_instruction(code, pointer, modes, input, &(&1 + &2))
        |> execute_instruction
      2 ->
        execute_four_parameters_instruction(code, pointer, modes, input, &(&1 * &2))
        |> execute_instruction
      3 ->
        execute_input(code, pointer, modes, input) |> execute_instruction
      4 ->
        execute_output(code, pointer, modes, input) |> execute_instruction
      5 ->
        execute_jump_if(code, pointer, modes, input, &(&1 != 0)) |> execute_instruction
      6 ->
        execute_jump_if(code, pointer, modes, input, &(&1 == 0)) |> execute_instruction
      7 ->
        execute_store_if(code, pointer, modes, input, &(&1 < &2)) |> execute_instruction
      8 ->
        execute_store_if(code, pointer, modes, input, &(&1 == &2)) |> execute_instruction
      99 ->
        {code, pointer, input}
    end
  end

  defp execute_input(code, pointer, _, input) do
    result_pointer = Enum.at(code, pointer + 1)
    code = List.replace_at(code, result_pointer, input)
    {code, pointer + 2, input}
  end

  defp execute_output(code, pointer, modes, _) do
    {elem} = get_params(code, pointer, modes, 1)
    {code, pointer + 2, elem}
  end

  defp execute_jump_if(code, pointer, modes, input, fun) do
    {elem, new_pointer} = get_params(code, pointer, modes, 2)
    {code, (if fun.(elem) do new_pointer else pointer + 3 end), input}
  end

  defp execute_store_if(code, pointer, modes, input, fun) do
    {first_elem, second_elem} = get_params(code, pointer, modes, 2)
    result_pointer = Enum.at(code, pointer + 3)
    value = if fun.(first_elem, second_elem) do 1 else 0 end
    code = List.replace_at(code, result_pointer, value)
    {code, pointer + 4, input}
  end

  defp execute_four_parameters_instruction(code, pointer, modes, input, fun) do
    {first_elem, second_elem} = get_params(code, pointer, modes, 2)
    result_pointer = Enum.at(code, pointer + 3)
    result = fun.(first_elem, second_elem)
    code = List.replace_at(code, result_pointer, result)
    {code, pointer + 4, input}
  end

  defp get_params(code, pointer, modes, count) do
    1..count |>
    Enum.map(fn n ->
      index_or_value = Enum.at(code, pointer + n)
      if Enum.at(modes, n - 1) == 0 do
        Enum.at(code, index_or_value)
      else
        index_or_value
      end
    end)
    |> List.to_tuple
  end
end

defmodule IntcodeSources do
  def get_code(filename) do
    File.read!(filename)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Day5 do
  def part1(filename) do
    execute_program(filename, 1)
  end

  def part2(filename) do
    execute_program(filename, 5)
  end

  defp execute_program(filename, input) do
    code = IntcodeSources.get_code(filename)
    IntcodeComputer.execute_program(code, input)
  end
end
