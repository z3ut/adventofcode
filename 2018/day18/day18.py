area = []
area_history = []

NUMBER_OF_TURNS_FIRST = 10
NUMBER_OF_TURNS_SECOND = 1000000000
AREA_SIZE = 50

OPEN = '.'
TREE = '|'
LUMBERYARD = "#"

with open("input.txt") as f:
    for line in f:
        area.append(list(line))

neighbour_indexes = [
    (-1, -1),   (0, -1),    (1, -1),
    (-1, 0),                (1, 0),
    (-1, 1),    (0, 1 ),    (1, 1)
]

def get_neighbour(area, x, y):
    global AREA_SIZE
    neighbours = []

    for n in neighbour_indexes:
        nx = x + n[0]
        ny = y + n[1]
        if 0 <= nx <= AREA_SIZE - 1 and 0 <= ny <= AREA_SIZE - 1:
            neighbours.append(area[ny][nx])
    
    return neighbours

def get_resource_value(area):
    trees = area_string.count(TREE)
    lumberyards = area_string.count(LUMBERYARD)
    return trees * lumberyards

for i in range(1, NUMBER_OF_TURNS_SECOND):
    new_area = [[None] * AREA_SIZE for _ in range(AREA_SIZE)]
    for y in range(AREA_SIZE):
        for x in range(AREA_SIZE):
            neighbours = get_neighbour(area, x, y)
            new_area[y][x]  = area[y][x]
            if area[y][x] == OPEN:
                if neighbours.count(TREE) >= 3:
                    new_area[y][x] = TREE
            elif area[y][x] == TREE:
                if neighbours.count(LUMBERYARD) >= 3:
                    new_area[y][x] = LUMBERYARD
            elif area[y][x] == LUMBERYARD:
                if neighbours.count(LUMBERYARD) == 0 or neighbours.count(TREE) == 0:
                    new_area[y][x] = OPEN
    area = new_area
    
    area_string = "".join("".join(line) for line in area)

    if i == NUMBER_OF_TURNS_FIRST:
        print(get_resource_value(area_string))

    if area_string in area_history:
        area_index = area_history.index(area_string)
        period_step = i - area_index
        while area_index % period_step != (NUMBER_OF_TURNS_SECOND) % period_step:
            area_index += 1
        area_answer = area_history[area_index]
        print(get_resource_value(area_answer))
        exit(0)

    area_history.append(area_string)
