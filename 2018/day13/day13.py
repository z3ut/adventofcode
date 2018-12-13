from enum import Enum

TOP = (0, -1)
RIGHT = (1, 0)
BOTTOM = (0, 1)
LEFT = (-1, 0)

class Cart:
    def __init__(self, x, y, direction):
        self.x = x
        self.y = y
        self.direction = direction
        self.intersections_passed = 0
    
    def move(self):
        self.x += self.direction[0]
        self.y += self.direction[1]
    
    def move_to(self, direction):
        self.direction = direction
        self.x += self.direction[0]
        self.y += self.direction[1]

tracks = {}
carts = []

char_direction = {
    "^": TOP,
    "v": BOTTOM,
    "<": LEFT,
    ">": RIGHT
}
direction_to_path = {
    "^": "|",
    "v": "|",
    "<": "-",
    ">": "-"
}

with open("input.txt") as f:
    for y, line in enumerate(f):
        for x, c in enumerate(line):
            if c in [ "-", "|", "/", "\\", "+" ]:
                tracks[(x, y)] = c
            elif c in [ "^", "v",  "<", ">" ]:
                cart = Cart(x, y, char_direction[c])
                carts.append(cart)
                tracks[(x, y)] = direction_to_path[c]

while len(carts) > 1:
    carts = sorted(carts, key=lambda cart:(cart.y, cart.x))
    for c in carts:
        if tracks[(c.x, c.y)] == "+":
            if c.intersections_passed % 3 == 0:
                if c.direction == TOP:
                    c.move_to(LEFT)
                elif c.direction == RIGHT:
                    c.move_to(TOP)
                elif c.direction == BOTTOM:
                    c.move_to(RIGHT)
                else:
                    c.move_to(BOTTOM)
            elif c.intersections_passed % 3 == 1:
                if c.direction == TOP:
                    c.move_to(TOP)
                elif c.direction == RIGHT:
                    c.move_to(RIGHT)
                elif c.direction == BOTTOM:
                    c.move_to(BOTTOM)
                else:
                    c.move_to(LEFT)
            else:
                if c.direction == TOP:
                    c.move_to(RIGHT)
                elif c.direction == RIGHT:
                    c.move_to(BOTTOM)
                elif c.direction == BOTTOM:
                    c.move_to(LEFT)
                else:
                    c.move_to(TOP)
            c.intersections_passed += 1
        elif tracks[(c.x, c.y)] in [ "-", "|" ]:
            c.move()
        elif tracks[(c.x, c.y)] == "/":
            if c.direction == TOP:
                c.move_to(RIGHT)
            elif c.direction == RIGHT:
                c.move_to(TOP)
            elif c.direction == BOTTOM:
                c.move_to(LEFT)
            else:
                c.move_to(BOTTOM)
        elif tracks[(c.x, c.y)] == "\\":
            if c.direction == TOP:
                c.move_to(LEFT)
            elif c.direction == RIGHT:
                c.move_to(BOTTOM)
            elif c.direction == BOTTOM:
                c.move_to(RIGHT)
            else:
                c.move_to(TOP)
        else:
            print("Unknown track char", tracks[(c.x, c.y)])

        if (c.x, c.y) in [(cc.x, cc.y) for cc in carts if cc.x == c.x and cc.y == c.y and cc != c]:
            print("collision", c.x, c.y)
            carts = [cc for cc in carts if cc.x != c.x or cc.y != c.y]

for c in carts:
    print(c.x, c.y)
