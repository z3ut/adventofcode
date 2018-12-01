package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const inputFileName = "input.txt"
const numberOfIterationsPartOne = 10000
const numberOfIterationsPartTwo = 10000000

type Position struct {
	y int
	x int
}

type NodeStatus rune

const (
	INFECTED = NodeStatus('#')
	CLEAN    = NodeStatus('.')
	WEAKENED = NodeStatus('w')
	FLAGGED  = NodeStatus('f')
)

type Direction rune

const (
	NORTH = Direction('N')
	WEST  = Direction('W')
	SOUTH = Direction('S')
	EAST  = Direction('E')
)

func main() {
	infectedPartOne := computePartOneInfected()
	infectedPartTwo := computePartTwoInfected()

	fmt.Println(infectedPartOne, infectedPartTwo)
}

func computePartOneInfected() int {
	nodes, positionX, positionY := getNodesAndStartPosition(inputFileName)

	currentDirection := NORTH
	burstsWithInfection := 0

	for i := 0; i < numberOfIterationsPartOne; i++ {
		position := Position{x: positionX, y: positionY}
		nodeStatus, exist := nodes[position]

		if !exist || nodeStatus == CLEAN {
			currentDirection = turnDirectionLeft(currentDirection)
			nodes[position] = INFECTED
			burstsWithInfection++
		} else {
			currentDirection = turnDirectionRight(currentDirection)
			nodes[position] = CLEAN
		}

		positionX, positionY = computeNextCoords(currentDirection, positionX, positionY)
	}

	return burstsWithInfection
}

func computePartTwoInfected() int {
	nodes, positionX, positionY := getNodesAndStartPosition(inputFileName)

	currentDirection := NORTH
	burstsWithInfection := 0

	for i := 0; i < numberOfIterationsPartTwo; i++ {
		position := Position{x: positionX, y: positionY}
		nodeStatus, exist := nodes[position]

		if !exist || nodeStatus == CLEAN {
			currentDirection = turnDirectionLeft(currentDirection)
			nodes[position] = WEAKENED
		} else if nodeStatus == INFECTED {
			currentDirection = turnDirectionRight(currentDirection)
			nodes[position] = FLAGGED
		} else if nodeStatus == WEAKENED {
			nodes[position] = INFECTED
			burstsWithInfection++
		} else {
			currentDirection = reverseDirection(currentDirection)
			nodes[position] = CLEAN
		}

		positionX, positionY = computeNextCoords(currentDirection, positionX, positionY)
	}

	return burstsWithInfection
}

func turnDirectionRight(direction Direction) Direction {
	switch direction {
	case NORTH:
		return EAST
	case EAST:
		return SOUTH
	case SOUTH:
		return WEST
	case WEST:
		return NORTH
	default:
		panic("Wrong direction input")
	}
}

func turnDirectionLeft(direction Direction) Direction {
	switch direction {
	case NORTH:
		return WEST
	case WEST:
		return SOUTH
	case SOUTH:
		return EAST
	case EAST:
		return NORTH
	default:
		panic("Wrong direction input")
	}
}

func reverseDirection(direction Direction) Direction {
	switch direction {
	case NORTH:
		return SOUTH
	case EAST:
		return WEST
	case SOUTH:
		return NORTH
	case WEST:
		return EAST
	default:
		panic("Wrong direction input")
	}
}

func computeNextCoords(direction Direction, X, Y int) (int, int) {
	switch direction {
	case NORTH:
		return X, Y - 1
	case EAST:
		return X + 1, Y
	case SOUTH:
		return X, Y + 1
	case WEST:
		return X - 1, Y
	default:
		panic("Wrong direction input")
	}
}

func getNodesAndStartPosition(fileName string) (map[Position]NodeStatus, int, int) {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	nodes := make(map[Position]NodeStatus)

	rows := strings.Split(string(data), "\r\n")

	for i, row := range rows {
		for j, symbol := range row {
			if NodeStatus(symbol) == INFECTED {
				position := Position{x: j, y: i}
				nodes[position] = INFECTED
			}
		}
	}

	return nodes, len(rows) / 2, len(rows[0]) / 2
}
