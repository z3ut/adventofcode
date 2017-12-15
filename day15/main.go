package main

import (
	"fmt"
	"math"
)

const generatorAStart = 883
const generatorBStart = 879

const generatorAFactor = 16807
const generatorBFactor = 48271

const generatorAModCheck = 4
const generatorBModCheck = 8

const remainderDivider = 2147483647

const numberOfCycles1 = 40000000
const numberOfCycles2 = 5000000

const meaningPartOfValues = 65536

func main() {
	firstTask()
	secondTask()
}

func firstTask() {
	numberOfMatches := 0

	valueA := generatorAStart
	valueB := generatorBStart

	for i := 0; i < numberOfCycles1; i++ {
		valueA = generateValue(valueA, generatorAFactor, remainderDivider)
		valueB = generateValue(valueB, generatorBFactor, remainderDivider)

		if isValuesMatchForJudge(valueA, valueB) {
			numberOfMatches++
		}
	}

	fmt.Println(numberOfMatches)
}

func secondTask() {
	numberOfMatches := 0

	valueA := generatorAStart
	valueB := generatorBStart

	for i := 0; i < numberOfCycles2; i++ {
		for {
			valueA = generateValue(valueA, generatorAFactor, remainderDivider)
			if math.Mod(float64(valueA), float64(generatorAModCheck)) == 0 {
				break
			}
		}

		for {
			valueB = generateValue(valueB, generatorBFactor, remainderDivider)
			if math.Mod(float64(valueB), float64(generatorBModCheck)) == 0 {
				break
			}
		}

		if isValuesMatchForJudge(valueA, valueB) {
			numberOfMatches++
		}
	}

	fmt.Println(numberOfMatches)
}

func generateValue(previousValue, factor, divider int) int {
	return int(math.Mod(float64(previousValue*factor), float64(divider)))
}

func isValuesMatchForJudge(value1, value2 int) bool {
	return math.Mod(float64(value1), float64(meaningPartOfValues)) ==
		math.Mod(float64(value2), float64(meaningPartOfValues))
}
