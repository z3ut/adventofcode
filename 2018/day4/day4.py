import re
from datetime import datetime
from collections import defaultdict

f = open("input.txt", "r")

logs = []

for l in f:
    d = re.search(r"\[(.+)\] (.+)", l)
    log_date = datetime.strptime(d.group(1), "%Y-%m-%d %H:%M")
    logs.append((log_date, d.group(2)))

logs.sort()


guard_id = None
falls_asleep_time = None

guards_total_sleep_time = defaultdict(int)
guards_minute_sleep_count = defaultdict(int)

for l in logs:
    if "#" in l[1]:
        guard_id = int(re.search(r'\d+', l[1]).group(0))
    elif "falls asleep" in l[1]:
        falls_asleep_time = l[0]
    else:
        for m in range(falls_asleep_time.minute, l[0].minute):
            guards_minute_sleep_count[(guard_id, m)] += 1
        guards_total_sleep_time[guard_id] += l[0].minute - falls_asleep_time.minute

guard_with_most_sleep_time = max(guards_total_sleep_time, key=guards_total_sleep_time.get)
guard_with_most_sleepy_minute = max(guards_minute_sleep_count, key=guards_minute_sleep_count.get)

guard_max_sleep_minute = 0
guard_max_sleep_count = 0

for k, v in guards_minute_sleep_count.items():
    if k[0] != guard_with_most_sleep_time:
        continue
    if v > guard_max_sleep_count:
        guard_max_sleep_count = v
        guard_max_sleep_minute = k[1]

print(guard_with_most_sleep_time * guard_max_sleep_minute)

print(guard_with_most_sleepy_minute[0] * guard_with_most_sleepy_minute[1])
