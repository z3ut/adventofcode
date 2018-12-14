board = [ 3, 7 ]
number_of_recipies = 704321
first_elf_recipe_index = 0
second_elf_recipe_index = 1

for i in range(number_of_recipies * 50):
    new_recipie = board[first_elf_recipe_index] + board[second_elf_recipe_index]
    if new_recipie > 9:
        board.append(new_recipie // 10)
    board.append(new_recipie % 10)

    first_elf_recipe_index = (first_elf_recipe_index + board[first_elf_recipe_index] + 1) % len(board)
    second_elf_recipe_index = (second_elf_recipe_index + board[second_elf_recipe_index] + 1) % len(board)

answer = board[number_of_recipies:number_of_recipies + 10]

print("".join(map(str, answer)))

print("".join(map(str, board)).find(str(number_of_recipies)))

