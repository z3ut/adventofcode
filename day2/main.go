package main

import (
	"fmt"
	"strings"
	"math"
	"strconv"
	"io/ioutil"
)

const inputFile = "input.txt"

type rowChecksumCalculatorFunc func(row []int) int

func main() {
	spreadsheet := getSpreadsheet(inputFile)

	firstTaskChecksum := calculateChecksum(spreadsheet, firstTaskRowChecksumCalculator)
	secondTaskChecksum := calculateChecksum(spreadsheet, secondTaskRowChecksumCalculator)

	fmt.Printf("%v\n%v\n", firstTaskChecksum, secondTaskChecksum)
}

func getSpreadsheet(fileName string) [][]int {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var values [][]int

	for _, row := range strings.Split(string(data), "\n") {
		var rowValues []int

		for _, valueString := range strings.Fields(row) {
			value, err := strconv.Atoi(valueString)
			if err != nil {
				panic("Error parsing string value as int")
			}
			rowValues = append(rowValues, value)
		}

		values = append(values, rowValues)
	}

	return values
}

func calculateChecksum(spreadsheet [][]int, calculator rowChecksumCalculatorFunc) int {
	checksum := 0

	for _, row := range spreadsheet {
		checksum += calculator(row)
	}

	return checksum
}

func firstTaskRowChecksumCalculator(row []int) int {
	min, max := findMinAndMax(row)
	return max - min
}

func findMinAndMax(array []int) (int, int) {
	if len(array) == 0 {
		panic("Received empty array to search min/max elements")
	}

	min := array[0]
	max := array[0]

	for _, v := range array {
		if v < min {
			min = v
		}
		if max < v {
			max = v
		}
	}

	return min, max
}

func secondTaskRowChecksumCalculator(row []int) int {
	for _, value := range row {
		for _, divisor := range row {
			if divisor == 0 {
				panic("Get zero value while searching for divider")
			}
			if value != divisor && math.Mod(float64(value), float64(divisor)) == 0 {
				return value / divisor
			}
		}
	}
	panic("Evenly divisible values were not found")
}
