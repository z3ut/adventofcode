initial_state = {}
vocabulary = {}

NUMBER_OF_GENERATIONS = 20

with open("input.txt") as f:
    for i, c in enumerate(f.readline()[15:-1]):
        initial_state[i] = c
    f.readline()
    for line in f:
        vocabulary[line[:5]] = line[9:10]

def get_new_generation(state, vocabulary):
    new_state = {}
    min_index = min(state)
    max_index = max(state)
    for i in range(min_index - 2, max_index + 3):
        line = "".join(state.get(ii, ".") for ii in range(i - 2, i + 3))
        new_state[i] = vocabulary.get(line, ".")
    return new_state

current_state = initial_state

for generation in range(1, NUMBER_OF_GENERATIONS + 1):
    current_state = get_new_generation(current_state, vocabulary)
    pots_sum = sum([i for i, s in current_state.items() if s == "#"])
    print(generation, pots_sum)

# part2:
# 1318 -> 59430
# 1319 -> 59475
# 1320 -> 59520
# next generation: previous + 45
# 50000000000 -> 59430 + (50000000000 - 1318) * 45 = 2250000000120
