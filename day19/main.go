package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const inputFileName = "input.txt"

func main() {
	diagram := getDiagram(inputFileName)

	currentX := 0
	currentY := 0
	direction := 'S'
	encounteredChars := ""
	currentStep := 0

	for i, v := range diagram[0] {
		if v == '|' {
			currentX = i
			break
		}
	}

	for {
		currentStep++

		if direction == 'N' {
			currentY--
		}
		if direction == 'E' {
			currentX++
		}
		if direction == 'S' {
			currentY++
		}
		if direction == 'W' {
			currentX--
		}

		if currentX < 0 || currentY < 0 || currentX >= len(diagram[0]) || currentY >= len(diagram) {
			panic("Current position is outside of diagram")
		}

		currentSymbol := diagram[currentY][currentX]

		if 'A' <= currentSymbol && currentSymbol <= 'Z' {
			encounteredChars += string(currentSymbol)
		}

		if currentSymbol == ' ' {
			fmt.Println(encounteredChars, currentStep)
			return
		}

		if currentSymbol != '+' {
			continue
		}

		if direction != 'S' && diagram[currentY-1][currentX] != ' ' {
			direction = 'N'
			continue
		}
		if direction != 'E' && diagram[currentY][currentX-1] != ' ' {
			direction = 'W'
			continue
		}
		if direction != 'N' && diagram[currentY+1][currentX] != ' ' {
			direction = 'S'
			continue
		}
		if direction != 'W' && diagram[currentY][currentX+1] != ' ' {
			direction = 'E'
			continue
		}
	}
}

func getDiagram(fileName string) [][]rune {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var diagram [][]rune
	for _, row := range strings.Split(string(data), "\n") {
		diagram = append(diagram, []rune(row))
	}

	return diagram
}
