defmodule OutputResult do
  defstruct [:exit?, :elem, :code, :pointer, :input]
end

defmodule ComputerState do
  defstruct [:code, :pointer, :input]
end

defmodule IntcodeComputer do
  def execute_instruction({code, pointer, input, loop?}) do
    instruction = Enum.at(code, pointer)
    digits = Integer.digits(instruction)
    modes = List.duplicate(0, 4) ++ digits |> Enum.slice(-5, 3) |> Enum.reverse
    opcode = digits |> Enum.take(-2) |> Integer.undigits
    case opcode do
      1 ->
        execute_four_parameters_instruction(code, pointer, modes, input, loop?, &(&1 + &2))
        |> execute_instruction
      2 ->
        execute_four_parameters_instruction(code, pointer, modes, input, loop?, &(&1 * &2))
        |> execute_instruction
      3 ->
        execute_input(code, pointer, modes, input, loop?) |> execute_instruction
      4 ->
        {code, pointer, input, elem} = execute_output(code, pointer, modes, input, loop?)
        if loop? do
          %OutputResult{exit?: false, elem: elem, code: code, pointer: pointer, input: input}
        else 
          execute_instruction({code, pointer, input, loop?})
        end
      5 ->
        execute_jump_if(code, pointer, modes, input, loop?, &(&1 != 0)) |> execute_instruction
      6 ->
        execute_jump_if(code, pointer, modes, input, loop?, &(&1 == 0)) |> execute_instruction
      7 ->
        execute_store_if(code, pointer, modes, input, loop?, &(&1 < &2)) |> execute_instruction
      8 ->
        execute_store_if(code, pointer, modes, input, loop?, &(&1 == &2)) |> execute_instruction
      99 ->
        %OutputResult{exit?: true, elem: hd(input), code: code, pointer: pointer, input: input}
    end
  end

  defp execute_input(code, pointer, _, input, loop?) do
    result_pointer = Enum.at(code, pointer + 1)
    [input_value | remaining_input] = input
    code = List.replace_at(code, result_pointer, input_value)
    {code, pointer + 2, remaining_input, loop?}
  end

  defp execute_output(code, pointer, modes, input, loop?) do
    {elem} = get_params(code, pointer, modes, 1)
    {code, pointer + 2, (if loop?, do: input, else: input ++ [elem]), elem}
  end

  defp execute_jump_if(code, pointer, modes, input, loop?, fun) do
    {elem, new_pointer} = get_params(code, pointer, modes, 2)
    {code, (if fun.(elem) do new_pointer else pointer + 3 end), input, loop?}
  end

  defp execute_store_if(code, pointer, modes, input, loop?, fun) do
    {first_elem, second_elem} = get_params(code, pointer, modes, 2)
    result_pointer = Enum.at(code, pointer + 3)
    value = if fun.(first_elem, second_elem) do 1 else 0 end
    code = List.replace_at(code, result_pointer, value)
    {code, pointer + 4, input, loop?}
  end

  defp execute_four_parameters_instruction(code, pointer, modes, input, loop?, fun) do
    {first_elem, second_elem} = get_params(code, pointer, modes, 2)
    result_pointer = Enum.at(code, pointer + 3)
    result = fun.(first_elem, second_elem)
    code = List.replace_at(code, result_pointer, result)
    {code, pointer + 4, input, loop?}
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

defmodule ListHelpers do
  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
end

defmodule Day7 do
  def part1(filename) do
    code = IntcodeSources.get_code(filename)

    0..4
    |> Enum.to_list
    |> ListHelpers.permutations
    |> Enum.map(fn conf ->
      Enum.reduce(conf, 0, fn p, acc ->
        output_result = IntcodeComputer.execute_instruction({code, 0, [p, acc], false})
        output_result.elem
      end)
    end)
    |> Enum.max
  end

  def part2(filename) do
    code = IntcodeSources.get_code(filename)

    5..9
    |> Enum.to_list
    |> ListHelpers.permutations
    |> Enum.map(fn conf ->
      Enum.map(conf, fn n ->
        %ComputerState{code: code, pointer: 0, input: [n]}
      end)
    end)
    |> Enum.map(fn computer_states ->
      execute_before_output({computer_states, 0, 0})
    end)
    |> Enum.max
  end

  def execute_before_output({states, curr_index, new_input}) do
    state = Enum.at(states, curr_index)

    result = IntcodeComputer.execute_instruction(
      {state.code, state.pointer, state.input ++ [new_input], true})

    if result.exit? do
      result.elem
    else
      new_states = List.replace_at(states, curr_index,
        %ComputerState{code: result.code, pointer: result.pointer, input: result.input})

      execute_before_output({new_states, rem(curr_index + 1, length(states)), result.elem})
    end
  end
end
