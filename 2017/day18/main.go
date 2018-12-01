package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"time"
)

const inputFileName = "input.txt"

type Registers map[string]int

func main() {
	instructions := getInstructions(inputFileName)

	registers := make(Registers)
	frequencyAfterExecuting := getFrequencyAfterExecuting(registers, instructions)
	fmt.Println(frequencyAfterExecuting)

	registers0 := make(Registers)
	registers0["p"] = 0
	registers1 := make(Registers)
	registers1["p"] = 1
	sending0 := make(chan int, 10000)
	sending1 := make(chan int, 10000)
	result0 := make(chan int, 10000)
	result1 := make(chan int, 10000)

	go executeInstructionsAndCountSendings(registers0, instructions, sending0, sending1, result0)
	go executeInstructionsAndCountSendings(registers1, instructions, sending1, sending0, result1)
	sendingCount1 := <-result1

	fmt.Println(sendingCount1)
}

func getFrequencyAfterExecuting(registers Registers, instructions [][]string) int {
	currentPosition := 0
	lastPlayedFrequency := 0

	for {
		instruction := instructions[currentPosition]

		switch instruction[0] {
		case "snd":
			lastPlayedFrequency = getInstructionValue(registers, instruction[1])
		case "set":
			registers[instruction[1]] = getInstructionValue(registers, instruction[2])
		case "add":
			registers[instruction[1]] += getInstructionValue(registers, instruction[2])
		case "mul":
			registers[instruction[1]] *= getInstructionValue(registers, instruction[2])
		case "mod":
			registers[instruction[1]] %= getInstructionValue(registers, instruction[2])
		case "rcv":
			if getInstructionValue(registers, instruction[1]) > 0 {
				return lastPlayedFrequency
			}
		case "jgz":
			if getInstructionValue(registers, instruction[1]) > 0 {
				currentPosition += getInstructionValue(registers, instruction[2])
				continue
			}
		default:
			panic("Unknown instruction")
		}
		currentPosition++
	}
}

func executeInstructionsAndCountSendings(registers Registers, instructions [][]string, sending, receiver, sendingCountChannel chan int) int {
	currentPosition := 0
	sendingCount := 0

	for {
		instruction := instructions[currentPosition]

		switch instruction[0] {
		case "snd":
			sending <- getInstructionValue(registers, instruction[1])
			sendingCount++
		case "set":
			registers[instruction[1]] = getInstructionValue(registers, instruction[2])
		case "add":
			registers[instruction[1]] += getInstructionValue(registers, instruction[2])
		case "mul":
			registers[instruction[1]] *= getInstructionValue(registers, instruction[2])
		case "mod":
			registers[instruction[1]] %= getInstructionValue(registers, instruction[2])
		case "rcv":
			select {
			case value := <-receiver:
				registers[instruction[1]] = value
			case <-time.After(100 * time.Millisecond):
				sendingCountChannel <- sendingCount
				return sendingCount
			}
		case "jgz":
			if getInstructionValue(registers, instruction[1]) > 0 {
				currentPosition += getInstructionValue(registers, instruction[2])
				continue
			}
		default:
			panic("Unknown instruction")
		}
		currentPosition++
	}
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
