from collections import defaultdict, deque

NUMBER_OF_PLAYERS = 431
LAST_MARBLE_WORTH = 7095000
NUMBER_OF_MARBLES = LAST_MARBLE_WORTH + 1

circle = deque([0])
players_score = defaultdict(int)

for marble in range(1, NUMBER_OF_MARBLES):
    if marble and marble % 23 == 0:
        circle.rotate(7)
        players_score[marble % NUMBER_OF_PLAYERS] += marble + circle.pop()
        circle.rotate(-1)
    else:
        circle.rotate(-1)
        circle.append(marble)

print(max(players_score.values()))
