package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"

type Registers map[string]int

func main() {
	instructions := getInstructions(inputFileName)
	registers := make(Registers)

	currentPosition := 0
	numberOfMulCalls := 0

	for {
		if currentPosition >= len(instructions) {
			break
		}

		instruction := instructions[currentPosition]
		switch instruction[0] {
		case "set":
			registers[instruction[1]] = getInstructionValue(registers, instruction[2])
		case "sub":
			registers[instruction[1]] -= getInstructionValue(registers, instruction[2])
		case "mul":
			registers[instruction[1]] *= getInstructionValue(registers, instruction[2])
			numberOfMulCalls++
		case "jnz":
			if getInstructionValue(registers, instruction[1]) != 0 {
				currentPosition += getInstructionValue(registers, instruction[2])
				continue
			}
		default:
			panic("Unknown instruction")
		}
		currentPosition++
	}

	fmt.Println(numberOfMulCalls)

	b := 93*100 + 100000
	c := b + 17000
	h := 0

	for n := b; n <= c; n += 17 {
		for d := 2; d <= int(math.Sqrt(float64(n))); d++ {
			if n%d == 0 {
				h++
				break
			}
		}
	}

	fmt.Println(h)
}

func getInstructionValue(registers Registers, registerOrNumber string) int {
	value, err := strconv.Atoi(registerOrNumber)
	if err != nil {
		return registers[registerOrNumber]
	}
	return value
}

func getInstructions(fileName string) [][]string {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var instructions [][]string

	for _, row := range strings.Split(string(data), "\n") {
		instructions = append(instructions, strings.Fields(row))
	}

	return instructions
}
