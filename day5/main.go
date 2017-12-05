package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const inputFile = "input.txt"

type changeInstructionsFunc func(instructions []int, previousIndex, currentIndex int)

func main() {
	instructions := getInstructions(inputFile)
	input1 := append([]int(nil), instructions...)
	input2 := append([]int(nil), instructions...)

	steps1 := getNumberOfStepsToJumpOutside(input1, task1ChangeInstructions)
	steps2 := getNumberOfStepsToJumpOutside(input2, task2ChangeInstructions)

	fmt.Printf("%v\n%v\n", steps1, steps2)
}

func getInstructions(fileName string) []int {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var instructions []int

	for _, row := range strings.Split(string(data), "\r\n") {
		value, err := strconv.Atoi(row)
		if err != nil {
			panic("Error parsing string value as int")
		}
		instructions = append(instructions, value)
	}

	return instructions
}

func getNumberOfStepsToJumpOutside(instructions []int, changeInstructions changeInstructionsFunc) int {
	currentPosition := 0
	currentStep := 0

	for 0 <= currentPosition && currentPosition < len(instructions) {
		currentStep++
		nextPosition := currentPosition + instructions[currentPosition]
		changeInstructions(instructions, currentPosition, nextPosition)
		currentPosition = nextPosition
	}

	return currentStep
}

func task1ChangeInstructions(instructions []int, previousIndex, currentIndex int) {
	instructions[previousIndex] = instructions[previousIndex] + 1
}

func task2ChangeInstructions(instructions []int, previousIndex, currentIndex int) {
	if instructions[previousIndex] >= 3 {
		instructions[previousIndex] = instructions[previousIndex] - 1
	} else {
		instructions[previousIndex] = instructions[previousIndex] + 1
	}
}
