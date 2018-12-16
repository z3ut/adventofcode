# Addition:

def addr(regs, a, b, c):
    regs[c] = regs[a] + regs[b]
    return regs

def addi(regs, a, b, c):
    regs[c] = regs[a] + b
    return regs


# Multiplication:

def mulr(regs, a, b, c):
    regs[c] = regs[a] * regs[b]
    return regs

def muli(regs, a, b, c):
    regs[c] = regs[a] * b
    return regs


# Bitwise AND:

def banr(regs, a, b, c):
    regs[c] = regs[a] & regs[b]
    return regs

def bani(regs, a, b, c):
    regs[c] = regs[a] & b
    return regs


# Bitwise OR:

def borr(regs, a, b, c):
    regs[c] = regs[a] | regs[b]
    return regs

def bori(regs, a, b, c):
    regs[c] = regs[a] | b
    return regs


# Assignment:

def setr(regs, a, b, c):
    regs[c] = regs[a]
    return regs

def seti(regs, a, b, c):
    regs[c] = a
    return regs


# Greater-than testing:

def gtir(regs, a, b, c):
    regs[c] = 1 if a > regs[b] else 0
    return regs

def gtri(regs, a, b, c):
    regs[c] = 1 if regs[a] > b else 0
    return regs

def gtrr(regs, a, b, c):
    regs[c] = 1 if regs[a] > regs[b] else 0
    return regs


# Equality testing:

def eqir(regs, a, b, c):
    regs[c] = 1 if a == regs[b] else 0
    return regs

def eqri(regs, a, b, c):
    regs[c] = 1 if regs[a] == b else 0
    return regs

def eqrr(regs, a, b, c):
    regs[c] = 1 if regs[a] == regs[b] else 0
    return regs

instructions = [
    addr, addi,
    mulr, muli,
    banr, bani,
    borr, bori,
    setr, seti,
    gtir, gtri, gtrr,
    eqir, eqri, eqrr
]

samples = []

with open("input_samples.txt") as f:
    lines = f.readlines()
    for i in range(0, len(lines), 4):
        before_state = [int(s) for s in lines[i][9:19].split(", ") if s.isdigit()]
        commands = [int(s) for s in lines[i + 1].split() if s.isdigit()]
        result = [int(s) for s in lines[i + 2][9:19].split(", ") if s.isdigit()]
        samples.append((before_state, commands, result))

def is_equal_arrays(arr1, arr2):
    if len(arr1) != len(arr2):
        return False
    for i in range(len(arr1)):
        if arr1[i] != arr2[i]:
            return False
    return True

commands_matches = { }
matches_three_or_more = 0

for s in samples:
    matches = []
    match_count = 0
    for i, instruction in enumerate(instructions):
        regs_after = instruction(s[0].copy(), s[1][1], s[1][2], s[1][3])
        if is_equal_arrays(s[2], regs_after):
            match_count += 1
            matches.append(i)
    if match_count >= 3:
        matches_three_or_more += 1
    
    commands_matches[s[1][0]] = matches

print(matches_three_or_more)

for _ in range(20):
    for command_index, commands in commands_matches.items():
        if len(commands) == 1:
            for k, v in commands_matches.items():
                if k != command_index:
                    commands_matches[k] = [v1 for v1 in v if v1 != commands[0]]

regs = [ 0, 0, 0, 0]

with open("input_program.txt") as f:
    for line in f:
        commands = [int(s) for s in line.split() if s.isdigit()]
        regs = instructions[commands_matches[commands[0]][0]](regs, commands[1], commands[2], commands[3])

print(regs)
