package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"reflect"
	"strconv"
	"strings"
)

const inputFile = "input.txt"

type memoryReallocationFunc func(memory []int)

func main() {
	memory := getInputMemory(inputFile)
	numberOfStepsForRepeatedMemory, repeatedCycle :=
		getNumberOfStepsWhenMemoryRepeat(memory, memoryReallocation)
	fmt.Printf("%v\n%v\n", numberOfStepsForRepeatedMemory, repeatedCycle)
}

func getInputMemory(fileName string) []int {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var memory []int

	for _, row := range strings.Fields(string(data)) {
		value, err := strconv.Atoi(row)
		if err != nil {
			panic("Error parsing string value as int")
		}
		memory = append(memory, value)
	}

	return memory
}

func getNumberOfStepsWhenMemoryRepeat(memory []int, memoryReallocation memoryReallocationFunc) (int, int) {
	configurationHistory := [][]int{}
	step := 0

	for {
		step++

		saveToHistoryConfiguration := make([]int, len(memory))
		copy(saveToHistoryConfiguration, memory)
		configurationHistory = append(configurationHistory, saveToHistoryConfiguration)

		memoryReallocation(memory)

		isMemoryWasBefore, repeatedStep := isMemoryWasBefore(memory, configurationHistory)

		if isMemoryWasBefore {
			return step, step - repeatedStep
		}
	}
}

func isMemoryWasBefore(currentMemory []int, memoryHistory [][]int) (bool, int) {
	for i, c := range memoryHistory {
		if reflect.DeepEqual(c, currentMemory) {
			return true, i
		}
	}
	return false, 0
}

func memoryReallocation(memory []int) {
	sourceBankIndex, sourceBank := getIndexAndMaxValue(memory)
	blocksToReallocate := sourceBank
	memory[sourceBankIndex] = 0

	for i := 1; i <= blocksToReallocate; i++ {
		nextBankIndex := int(math.Mod(float64(sourceBankIndex+i), float64(len(memory))))
		memory[nextBankIndex]++
	}
}

func getIndexAndMaxValue(array []int) (int, int) {
	if len(array) == 0 {
		panic("Empty array for searching max value")
	}

	maxValueIndex := 0
	maxValue := array[0]

	for i, v := range array {
		if maxValue < v {
			maxValueIndex = i
			maxValue = v
		}
	}

	return maxValueIndex, maxValue
}
