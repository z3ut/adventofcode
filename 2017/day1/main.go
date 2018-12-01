package main

import (
	"fmt"
	"math"
	"strconv"
	"io/ioutil"
)

const inputFile = "input.txt"

type getCompareIndexFunc func (index, length int) int

func main() {
	data, err := ioutil.ReadFile(inputFile)
	if err != nil {
		panic("Error while reading file")
	}

	number := string(data)

	var getFirstCompareIndex getCompareIndexFunc = func (index, length int) int {
		return int(math.Mod(float64(index + 1), float64(length)))
	}
	var getSecondCompareIndex getCompareIndexFunc = func (index, length int) int {
		return int(math.Mod(float64(index + length / 2), float64(length)))
	}

	firstPartAnswer := computeSumOfMatchedDigits(number, getFirstCompareIndex)
	secondPartAnswer := computeSumOfMatchedDigits(number, getSecondCompareIndex)

	fmt.Printf("%v\n%v", firstPartAnswer, secondPartAnswer)
}

func computeSumOfMatchedDigits(number string, getCompareIndex getCompareIndexFunc) int {
	sumOfMatchedDidgits := 0

	for i, currentCode := range(number) {
		compareCode := number[getCompareIndex(i, len(number))]

		if currentCode == rune(compareCode) {
			currentNumber, err := strconv.Atoi(string(currentCode))

			if err != nil {
				panic("Number string contains non-numeric code")
			}

			sumOfMatchedDidgits += currentNumber
		}
	}

	return sumOfMatchedDidgits
}
