package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strings"
)

const inputFileName = "input.txt"

func main() {
	allSteps := getSteps(inputFileName)

	maximumDistance := 0
	currentDistance := 0
	var currentSteps []string

	for _, step := range allSteps {
		currentSteps = append(currentSteps, step)
		currentDistance = getDistanceToStart(currentSteps)
		if currentDistance > maximumDistance {
			maximumDistance = currentDistance
		}
	}

	fmt.Printf("%v\n%v\n", currentDistance, maximumDistance)
}

func getSteps(fileName string) []string {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	return strings.Split(string(data), ",")
}

func getDistanceToStart(steps []string) int {
	x := 0
	y := 0
	z := 0

	for _, step := range steps {
		switch step {
		case "n":
			y++
			z--
		case "ne":
			x++
			z--
		case "se":
			x++
			y--
		case "s":
			y--
			z++
		case "sw":
			x--
			z++
		case "nw":
			x--
			y++
		}
	}

	return int(math.Max(math.Abs(float64(x)), math.Max(math.Abs(float64(y)), math.Abs(float64(z)))))
}
