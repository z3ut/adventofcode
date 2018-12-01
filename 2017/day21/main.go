package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const inputFileName = "input.txt"
const numberOfCyclesFirstTask = 5
const numberOfCyclesSecondTask = 18

const pixelOn = '#'
const pixelOff = '.'
const newRow = '/'

type EnchancementRule struct {
	input  string
	output string
}

type Grid [][]rune

func main() {
	enchancmentRules := getEnchancementRules(inputFileName)
	grid := convertStringToGrid(".#./..#/###")

	for cycle := 1; cycle <= numberOfCyclesSecondTask; cycle++ {
		widthOfSquare := 3
		if len(grid)%2 == 0 {
			widthOfSquare = 2
		}

		newGridWidth := (widthOfSquare + 1) * len(grid) / widthOfSquare
		newGrid := createEmptyGrid(newGridWidth)

		for x := 0; x < len(grid); x += widthOfSquare {
			for y := 0; y < len(grid); y += widthOfSquare {
				square := getSquareFromGrid(grid, x, y, widthOfSquare)
				transformedString := transformSquare(enchancmentRules, square)
				transformedGrid := convertStringToGrid(transformedString)
				newGrid = insertSquareToGrid(newGrid, transformedGrid, x*(widthOfSquare+1)/widthOfSquare, y*(widthOfSquare+1)/widthOfSquare)
			}
		}

		grid = newGrid

		if cycle == numberOfCyclesFirstTask {
			fmt.Println(countOnPixels(grid))
		}
	}

	fmt.Println(countOnPixels(grid))
}

func printGrid(grid Grid) {
	for _, row := range grid {
		for _, pixel := range row {
			fmt.Print(string(pixel))
		}
		fmt.Println()
	}
}

func countOnPixels(grid Grid) int {
	numberOfOnPixels := 0

	for i := 0; i < len(grid); i++ {
		for j := 0; j < len(grid); j++ {
			if grid[i][j] == pixelOn {
				numberOfOnPixels++
			}
		}
	}

	return numberOfOnPixels
}

func insertSquareToGrid(grid, square Grid, x, y int) Grid {
	for i := 0; i < len(square); i++ {
		for j := 0; j < len(square); j++ {
			grid[x+i][y+j] = square[i][j]
		}
	}

	return grid
}

func transformSquare(rules []EnchancementRule, square Grid) string {
	for {
		for turn := 0; turn < 4; turn++ {
			ok, output := tryTransformSquare(rules, square)
			if ok {
				return output
			}

			square = flipSquareHorizontal(square)
			ok, output = tryTransformSquare(rules, square)
			if ok {
				return output
			}

			square = flipSquareVertical(square)
			ok, output = tryTransformSquare(rules, square)
			if ok {
				return output
			}

			square = rotateSquareClockwise(square)
		}
		panic("Rules dont contain square rule")
	}
}

func tryTransformSquare(rules []EnchancementRule, square Grid) (bool, string) {
	squareString := convertGridToString(square)

	for _, rule := range rules {
		if rule.input == squareString {
			return true, rule.output
		}
	}

	return false, ""
}

func rotateSquareClockwise(square Grid) Grid {
	width := len(square)
	rotatedSquare := createEmptyGrid(width)

	for i := 0; i < width; i++ {
		for j := 0; j < width; j++ {
			rotatedSquare[width-j-1][i] = square[i][j]
		}
	}

	return rotatedSquare
}

func flipSquareHorizontal(square Grid) Grid {
	width := len(square)
	rotatedSquare := createEmptyGrid(width)

	for i := 0; i < width; i++ {
		for j := 0; j < width; j++ {
			rotatedSquare[width-i-1][j] = square[i][j]
		}
	}

	return rotatedSquare
}

func flipSquareVertical(square Grid) Grid {
	width := len(square)
	rotatedSquare := createEmptyGrid(width)

	for i := 0; i < width; i++ {
		for j := 0; j < width; j++ {
			rotatedSquare[i][width-j-1] = square[i][j]
		}
	}

	return rotatedSquare
}

func getSquareFromGrid(grid Grid, x, y, width int) Grid {
	square := createEmptyGrid(width)

	for i := x; i < x+width; i++ {
		for j := y; j < y+width; j++ {
			square[i-x][j-y] = grid[i][j]
		}
	}

	return square
}

func convertStringToGrid(input string) Grid {
	rows := strings.Split(input, string(newRow))
	grid := createEmptyGrid(len(rows))

	for y, row := range rows {
		for x, r := range row {
			grid[x][y] = r
		}
	}

	return grid
}

func convertGridToString(grid Grid) string {
	squareString := ""

	for y := 0; y < len(grid); y++ {
		for x := 0; x < len(grid); x++ {
			squareString += string(grid[x][y])
		}

		if y != len(grid)-1 {
			squareString += string(newRow)
		}
	}

	return squareString
}

func createEmptyGrid(width int) Grid {
	grid := make([][]rune, width)

	for i := 0; i < width; i++ {
		grid[i] = make([]rune, width)
	}

	return grid
}

func getEnchancementRules(fileName string) []EnchancementRule {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var enchancementRules []EnchancementRule

	for _, row := range strings.Split(string(data), "\r\n") {
		fields := strings.Fields(row)
		rule := EnchancementRule{fields[0], fields[2]}
		enchancementRules = append(enchancementRules, rule)
	}

	return enchancementRules
}
