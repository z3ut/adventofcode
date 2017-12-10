package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"
const inputArraySize = 256
const numberOfHashRounds = 64

func main() {
	firstTaskInput := getInputList(inputArraySize)
	firstTaskLengthSequence := getLengthSequence(inputFileName)
	firstTaskProcessedData, _, _ := knotRound(firstTaskInput, firstTaskLengthSequence, 0, 0)
	firstTaskAnswer := int(firstTaskProcessedData[0]) * int(firstTaskProcessedData[1])

	secondTaskInput := getInputList(inputArraySize)
	secondTaskLengthSequence := getLengthSequenceAsASCIICodes(inputFileName)
	secondTaskLengthSequence = append(secondTaskLengthSequence, 17, 31, 73, 47, 23)
	secondTaskProcessedData := knotHash(secondTaskInput, secondTaskLengthSequence, numberOfHashRounds)
	secondTaskHash := getSparseHash(secondTaskProcessedData)

	fmt.Printf("%v\n%x", firstTaskAnswer, secondTaskHash)
}

func getLengthSequence(fileName string) []byte {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var lengthSequence []byte
	lengthStringValues := strings.Split(string(data), ",")

	for _, v := range lengthStringValues {
		value, err := strconv.Atoi(v)
		if err != nil {
			panic("Error parsing string value as int")
		}
		lengthSequence = append(lengthSequence, byte(value))
	}

	return lengthSequence
}

func getInputList(inputSize int) []byte {
	list := make([]byte, inputSize)

	for i := 0; i < inputSize; i++ {
		list[i] = byte(i)
	}

	return list
}

func getLengthSequenceAsASCIICodes(fileName string) []byte {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var lengthSequence []byte
	currentIndex := 0

	for _, v := range string(data) {
		lengthSequence = append(lengthSequence, byte(v))
		currentIndex++
	}

	return lengthSequence
}

func getSparseHash(data []byte) []byte {
	var hash []byte

	for i := 0; i < len(data); i += 16 {
		hash = append(hash, xorBytes(data[i:min(i+16, len(data))]))
	}

	return hash
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func xorBytes(data []byte) byte {
	var output byte

	for _, b := range data {
		output = output ^ b
	}

	return output
}

func knotHash(data, lengthSequence []byte, rounds int) []byte {
	currentPosition := 0
	skip := 0

	for i := 0; i < rounds; i++ {
		data, currentPosition, skip = knotRound(data, lengthSequence, currentPosition, skip)
	}

	return data
}

func knotRound(data, lengthSequence []byte, currentPosition, skip int) ([]byte, int, int) {
	for _, length := range lengthSequence {
		shiftingArray := getCircularSubarrayFromPosition(data, currentPosition, int(length))
		reversedArray := reverseArray(shiftingArray)
		data = insertCircularValues(data, currentPosition, reversedArray)
		currentPosition = int(math.Mod(float64(currentPosition+int(length)+skip), float64(len(data))))
		skip++
	}

	return data, currentPosition, skip
}

func getCircularSubarrayFromPosition(array []byte, startPosition, length int) []byte {
	subarray := make([]byte, length)

	for i := 0; i < int(length); i++ {
		subarray[i] = array[int(math.Mod(float64(int(startPosition)+i), float64(len(array))))]
	}

	return subarray
}

func reverseArray(array []byte) []byte {
	output := make([]byte, len(array))

	for i, v := range array {
		output[len(output)-int(i)-1] = v
	}

	return output
}

func insertCircularValues(array []byte, position int, insertingArray []byte) []byte {
	for i := 0; i < len(insertingArray); i++ {
		array[int(math.Mod(float64(int(position)+i), float64(len(array))))] = insertingArray[i]
	}

	return array
}
