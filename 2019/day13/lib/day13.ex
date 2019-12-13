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
    code = Map.put(code, result_pointer, input)
    {code, pointer + 2, input, relative_base, loop?}
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


defmodule Day13 do
  def part1(filename) do
    IntcodeSources.get_code_normal_mode(filename)
    |> start_game(0, 0, [])
    |> Enum.chunk_every(3)
    |> Enum.filter(fn [_, _, id] -> id == 2 end)
    |> Enum.count
  end

  def part2(filename) do
    IntcodeSources.get_code_free_mode(filename)
    |> play_game
  end

  def start_game(code, pointer, relative_base, output) do
    res = IntcodeComputer.execute_instruction(
      {code, pointer, 0, relative_base, true})
    if res.exit? do
      output
    else
      start_game(res.code, res.pointer, res.relative_base, output ++ [res.elem])
    end
  end

  def play_game(code) do
    play_game(code, 0, 0, 0, 0, 0, 0)
  end

  def play_game(code, pointer, relative_base, input, ball_x, paddle_x, score) do
    res1 = IntcodeComputer.execute_instruction(
      {code, pointer, input, relative_base, true})
    if res1.exit? do
      score
    else
      res2 = IntcodeComputer.execute_instruction(
        {res1.code, res1.pointer, input, res1.relative_base, true})
      res3 = IntcodeComputer.execute_instruction(
        {res2.code, res2.pointer, input, res2.relative_base, true})

      new_score = if res1.elem == -1 and res2.elem == 0, do: res3.elem, else: score
      new_ball_x = if res3.elem == 4, do: res1.elem, else: ball_x
      new_paddle_x = if res3.elem == 3, do: res1.elem, else: paddle_x

      new_input = cond do
        new_ball_x < new_paddle_x -> -1
        new_ball_x == new_paddle_x -> 0
        new_ball_x > new_paddle_x -> 1
      end

      play_game(res3.code, res3.pointer, res3.relative_base,
        new_input, new_ball_x, new_paddle_x, new_score)
    end
  end
end
