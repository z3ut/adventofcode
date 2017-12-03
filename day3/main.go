package main

import (
	"fmt"
	"math"
)

const puzzleInput = 265149

type position struct {
	X int
	Y int
}

func main() {
	firstTaskPosition := findPositionInSpirale(puzzleInput)
	firtsTaskAnswer := manhattanDistance(firstTaskPosition.X, firstTaskPosition.Y)

	secondTaskAnswer := findInSumSpiraleFirstValueLargerThan(puzzleInput)
	fmt.Printf("%v\n%v\n", firtsTaskAnswer, secondTaskAnswer)
}

func findPositionInSpirale(number int) position {
	x := 0
	y := 0
	dx := 1
	dy := 0

	for i := 2; i <= number; i++ {
		x += dx
		y += dy

		if x == y || (x < 0 && -x == y) || (x > 0 && x-1 == -y) {
			dx, dy = -dy, dx
		}
	}

	return position{x, y}
}

func manhattanDistance(x, y int) int {
	return int(math.Abs(float64(x)) + math.Abs(float64(y)))
}

func findInSumSpiraleFirstValueLargerThan(number int) int {
	grid := make(map[position]int)
	grid[position{0, 0}] = 1

	neighborOffsets := [][]int{{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}}

	for i := 2; ; i++ {
		currentPosition := findPositionInSpirale(i)
		currentValue := 0

		for _, diff := range neighborOffsets {
			neighborPosition := position{currentPosition.X + diff[0], currentPosition.Y + diff[1]}
			neighbor, neighborExists := grid[neighborPosition]
			if neighborExists {
				currentValue += neighbor
			}
		}

		grid[currentPosition] = currentValue

		if currentValue > number {
			return currentValue
		}
	}
}
