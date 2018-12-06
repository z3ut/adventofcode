from collections import defaultdict

coords = []

with open("input.txt", "r") as f:
    for l in f.readlines():
        c = l.split(", ")
        coords.append((int(c[0]), int(c[1])))

x_coords = [c[0] for c in coords]
y_coords = [c[1] for c in coords]

x_border = max(x_coords)
y_border = max(y_coords)

def manhattan_distance(x1, y1, x2, y2):
    return abs(x1 - x2) + abs(y1 - y2)

closest_points_count = defaultdict(int)
infinite_areas = []

for x in range(1, x_border + 1):
    for y in range(1, y_border):
        distances_to_points = [manhattan_distance(x, y, p[0], p[1]) for p in coords]
        closest_distance = min(distances_to_points)
        if distances_to_points.count(closest_distance) == 1:
            closest_area = distances_to_points.index(closest_distance)
            closest_points_count[closest_area] += 1
            if closest_area not in infinite_areas and (x == 1 or x == x_border or y == 1 or y == y_border):
                infinite_areas.append(closest_area)

max_area = 0

for k, v in closest_points_count.items():
    if k in infinite_areas:
        continue
    max_area = max(max_area, v)

print(max_area)


closest_locations_region_points_count = 0

MAX_DISTANCE_SUM = 10000

for x in range(1, x_border + 1):
    for y in range(1, y_border + 1):
        distances = [manhattan_distance(x, y, c[0], c[1]) for c in coords]
        distances_sum = sum(distances)
        if distances_sum < MAX_DISTANCE_SUM:
            closest_locations_region_points_count += 1

print(closest_locations_region_points_count)
