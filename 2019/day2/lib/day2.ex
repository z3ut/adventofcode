defmodule IntcodeComputer do
  def execute_program(code) do
    [code, _] = execute_instruction(code, 0)
    code
  end

  defp execute_instruction(code, pointer) do
    case Enum.at(code, pointer) do
      1 ->
        [code, pointer] = execute_add(code, pointer)
        execute_instruction(code, pointer)
      2 ->
        [code, pointer] = execute_multiply(code, pointer)
        execute_instruction(code, pointer)
      99 ->
        [code, pointer]
    end
  end

  defp execute_add(code, pointer) do
    execute_four_parameters_instruction(code, pointer, &(&1 + &2))
  end

  defp execute_multiply(code, pointer) do
    execute_four_parameters_instruction(code, pointer, &(&1 * &2))
  end

  defp execute_four_parameters_instruction(code, pointer, fun) do
    [first_elem_pointer, second_elem_pointer, result_pointer] = Enum.slice(code, pointer + 1, 3)
    first_elem = Enum.at(code, first_elem_pointer)
    second_elem = Enum.at(code, second_elem_pointer)
    result = fun.(first_elem, second_elem)
    code = List.replace_at(code, result_pointer, result)
    [code, pointer + 4]
  end
end

defmodule IntcodeSources do
  def get_code(filename, noun, verb) do
    get_raw_code(filename)
    |> List.replace_at(1, noun)
    |> List.replace_at(2, verb)
  end

  defp get_raw_code(filename) do
    File.read!(filename)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Day2 do
  def part1(filename) do
    execute_program(filename, 12, 2) |> hd
  end

  def part2(filename) do
    for noun <- 0..99, verb <- 0..99 do [noun, verb] end
    |> Enum.find(fn [noun, verb] ->
      execute_program(filename, noun, verb) |> hd == 19690720 end)
    |> (fn [noun, verb] -> 100 * noun + verb end).()
  end

  defp execute_program(filename, noun, verb) do
    IntcodeSources.get_code(filename, noun, verb)
    |> IntcodeComputer.execute_program
  end
end
