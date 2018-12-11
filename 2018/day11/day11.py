GRID_SERIAL_NUMBER = 3999
GRID_SIZE = 300
SQUARE_SIZE = 3

grid = {}

def calculate_power_level(x, y, grid_serial_number):
    rack_id = x + 10
    power_level = (rack_id * y + grid_serial_number) * rack_id
    hundred_digit = int(power_level / 100) % 10
    return hundred_digit - 5

for x in range(1, GRID_SIZE + 1):
    for y in range(1, GRID_SIZE + 1):
        grid[(x, y)] = calculate_power_level(x, y, GRID_SERIAL_NUMBER)


def calculate_max_power_square(size):
    largest_square_coords = None
    largest_square_power = None

    for x in range(1, GRID_SIZE + 2 - size ):
        for y in range(1, GRID_SIZE + 2 - size):
            square_power = 0
            for xs in range(x, x + size):
                for ys in range(y, y + size):
                    square_power += grid[(xs, ys)]
            if not largest_square_power or square_power > largest_square_power:
                largest_square_power = square_power
                largest_square_coords = (x, y)
    return (largest_square_coords, largest_square_power)

print(calculate_max_power_square(SQUARE_SIZE))


grid_partial_sum = {}

for x in range(1, GRID_SIZE + 1):
    for y in range(1, GRID_SIZE + 1):
        grid_partial_sum[(x, y)] = grid[(x, y)] + grid_partial_sum.get((x - 1, y), 0) + grid_partial_sum.get((x, y - 1), 0) - grid_partial_sum.get((x - 1, y - 1), 0)


largest_square_coords = None
largest_square_power = None
largest_square_size = SQUARE_SIZE

for size in range(SQUARE_SIZE, GRID_SIZE):
    for x in range(1, GRID_SIZE + 1 - size):
        for y in range(1, GRID_SIZE + 1 - size):
            square_power = grid_partial_sum[(x + size, y + size)] + grid_partial_sum[(x, y)] - grid_partial_sum[(x + size, y)] - grid_partial_sum[(x, y + size)]
            if not largest_square_power or square_power > largest_square_power:
                largest_square_power = square_power
                largest_square_coords = (x + 1, y + 1)
                largest_square_size = size

print(largest_square_coords, largest_square_size, largest_square_power)
