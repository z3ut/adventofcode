with open("input.txt", "r") as f:
    polymer=f.read()

ASCII_CODE_CASE_DIFF = 32

def calculate_reacted_polymer(polymer):
    reacted_polymer = ""
    for l in polymer:
        if reacted_polymer and abs(ord(reacted_polymer[-1]) - ord(l)) == ASCII_CODE_CASE_DIFF:
            reacted_polymer = reacted_polymer[:-1]
        else:
            reacted_polymer += l
    return reacted_polymer

reacted_polymer = calculate_reacted_polymer(polymer)

print(len(reacted_polymer))

polymer_lengths_after_reacting = []

for c in range(ord("a"), ord("z") + 1):
    polymer_after_removing = polymer.replace(chr(c), "").replace(chr(c - ASCII_CODE_CASE_DIFF), "")
    reacted_polymer = calculate_reacted_polymer(polymer_after_removing)
    polymer_lengths_after_reacting.append(len(reacted_polymer))

print(min(polymer_lengths_after_reacting))
