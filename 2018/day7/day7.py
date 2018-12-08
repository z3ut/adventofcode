import re
from string import ascii_uppercase

steps_order = []
steps = ascii_uppercase

with open("input.txt", "r") as f:
    for l in f.readlines():
        m = re.search(r"Step ([A-Z]) must be finished before step ([A-Z]) can begin.", l)
        steps_order.append((m.group(1), m.group(2)))

completed_steps = []
required_steps = steps_order.copy()

while len(completed_steps) < len(steps):
    for c in steps:
        if c not in completed_steps and c not in [so[1] for so in required_steps]:
            completed_steps.append(c)
            required_steps = [so for so in required_steps if so[0] != c]
            break

print("".join(completed_steps))


NUMBER_OF_WORKERS = 5
STEP_BASE_TIME = 60

workers_tasks = [{ "task": None, "time_to_complete": None } for i in range(NUMBER_OF_WORKERS)]

completed_by_workers_steps = []
time = 0

while (len(completed_by_workers_steps) < len(steps)):
    for w in workers_tasks:
        if w["task"] != None:
            w["time_to_complete"] -= 1
            if w["time_to_complete"] == 0:
                completed_by_workers_steps.append(w["task"])
                w["task"] = None
                w["time_to_complete"] = None

    for c in steps:
        if c not in completed_by_workers_steps and len([s for s in steps_order if s[1] == c and s[0] not in completed_by_workers_steps]) == 0 and c not in [w["task"] for w in workers_tasks]:
            for w in workers_tasks:
                if w["task"] == None:
                    w["task"] = c
                    w["time_to_complete"] = STEP_BASE_TIME + ord(c) - ord("A") + 1
                    break

    if (len(completed_by_workers_steps) < len(steps)):
        time += 1

print(time)
