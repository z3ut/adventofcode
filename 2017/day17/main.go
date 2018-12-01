package main

import (
	"fmt"
	"math"
)

const numberOfSteps = 370
const countOfInsertsFirstTask = 2017
const countOfInsertsSecondTask = 50000000

func main() {
	var buffer = []int{0}
	currPosition := 0

	for i := 1; i <= countOfInsertsFirstTask; i++ {
		currPosition = int(math.Mod(float64(currPosition+numberOfSteps), float64(i)))

		var newBuffer []int
		newBuffer = append(newBuffer, buffer[:currPosition+1]...)
		newBuffer = append(newBuffer, i)
		newBuffer = append(newBuffer, buffer[currPosition+1:]...)

		currPosition++
		buffer = newBuffer
	}

	fmt.Println(buffer[int(math.Mod(float64(currPosition+1), float64(len(buffer))))])

	currPosition = 0
	zeroPositionStep := 0

	for i := 1; i <= countOfInsertsSecondTask; i++ {
		currPosition = int(math.Mod(float64(currPosition+numberOfSteps), float64(i)))

		if currPosition == 0 {
			zeroPositionStep = i
		}

		currPosition++
	}

	fmt.Println(zeroPositionStep)
}
