import sys
from time import sleep 

class Point:
    def __init__(self, x, y, vx, vy):
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy

points = []

with open("input.txt", "r") as f:
    for line in f:
        x = int(line[10:16])
        y = int(line[18:24])
        vx = int(line[36:38])
        vy = int(line[39:42])
        points.append(Point(x, y, vx, vy))

step = None
min_bbox = None

for i in range(9500, 10500):
    x_positions = [p.x + i * p.vx for p in points]
    y_positions = [p.y + i * p.vy for p in points]
    bbox = max(x_positions) - min(x_positions) + max(y_positions) - min(y_positions)
    if not min_bbox or min_bbox > bbox:
        step = i
        min_bbox = bbox

field =  [[" "] * 80 for j in range(20)]

for p in points:
    x = p.x + step * p.vx
    y = p.y + step * p.vy
    # print(y, x)
    field[y - 150][x - 130] = "#"

for l in field:
    print("".join(l))

print(step)
