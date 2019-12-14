defmodule Chemical do
  defstruct [:name, :quantity]
end

defmodule Pattern do
  defstruct [:chemicals, :result]
end

defmodule Nanofactory do
  def get_reactions(filename) do
    File.read!(filename)
    |> String.split(["\r", "\n", "\r\n"])
    |> Enum.map(fn reaction ->
      reaction
      |> String.replace("=>", ",")
      |> String.split(",")
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [quantity, name] ->
        %Chemical{name: name, quantity: String.to_integer(quantity)}
      end)
      |> Enum.reverse
      |> (fn [result | chemicals] ->
        %Pattern{chemicals: chemicals, result: result}
      end).()
    end)
  end

  def get_ingredients(reactions, chemical_name, quantity, leftovers) do
    if chemical_name == "ORE" do
      {quantity, leftovers}
    else
      reaction = Enum.find(reactions, fn r ->
        r.result.name == chemical_name
      end)

      element_leftover = Map.get(leftovers, chemical_name, 0)

      required_quantity = if element_leftover > 0 do
        max(quantity - element_leftover, 0)
      else
        quantity
      end

      leftovers_after_taking_element = Map.put(leftovers, chemical_name,
        max(element_leftover - quantity, 0))

      number_of_reactions = Float.ceil(required_quantity / reaction.result.quantity)

      would_be_produced_quantity = number_of_reactions * reaction.result.quantity

      leftovers_after_adding_produced_element_excess =
      if would_be_produced_quantity > required_quantity do
        Map.update(leftovers_after_taking_element, chemical_name, 0, fn curr_element_left ->
          curr_element_left + would_be_produced_quantity - required_quantity
        end)
      else
        leftovers_after_taking_element
      end

      {ore_consumed_after_creating_current, leftovers_after_creating_current} =
      Enum.reduce(reaction.chemicals, {0, leftovers_after_adding_produced_element_excess},
        fn c, {ore_consumed_for_reaction, current_leftovers} ->
          {ore_consumed, l} = get_ingredients(reactions, c.name,
            c.quantity * number_of_reactions, current_leftovers)
          {ore_consumed_for_reaction + ore_consumed, l}
        end)

      {ore_consumed_after_creating_current, leftovers_after_creating_current}
    end
  end
end

defmodule Day14 do
  def part1(filename) do
    reactions = Nanofactory.get_reactions(filename)
    {ore_consumed, _} = Nanofactory.get_ingredients(reactions, "FUEL", 1, %{})
    ore_consumed
  end

  def part2(filename) do
    reactions = Nanofactory.get_reactions(filename)
    calculate_maximum_bumber_of_fuel_for_ore(reactions, 0, 1000000000000, 1000000000000)
  end

  def calculate_maximum_bumber_of_fuel_for_ore(reactions, fuel_from, fuel_to, max_ore) do
    current_fuel = div(fuel_from + fuel_to, 2) + 1
    {ore_consumed, _} = Nanofactory.get_ingredients(reactions, "FUEL", current_fuel, %{})
    cond do
      fuel_from == fuel_to -> fuel_from
      ore_consumed < max_ore -> calculate_maximum_bumber_of_fuel_for_ore(
        reactions, current_fuel, fuel_to, max_ore)
      ore_consumed >= max_ore -> calculate_maximum_bumber_of_fuel_for_ore(
        reactions, fuel_from, current_fuel - 1, max_ore)
    end
  end
end
