package main

import (
	"encoding/hex"
	"fmt"
	"strconv"
)

const inputKey = "hxtvlmkl"

func main() {
	sumOfUsedSquares := 0
	var grid [][]int

	for i := 0; i < 128; i++ {
		keyString := inputKey + "-" + strconv.Itoa(i)
		hashHex := KnotHash(keyString)
		binary := convertHexToBinaryString(hashHex)

		currentRow := []int{}

		for _, b := range binary {
			if b == '1' {
				sumOfUsedSquares++
				currentRow = append(currentRow, 1)
			} else {
				currentRow = append(currentRow, 0)
			}
		}

		grid = append(grid, currentRow)
	}

	areas := 0

	for i, row := range grid {
		for j, s := range row {
			if s == 1 {
				areas++
				markSquareAndNeighboursVisited(grid, i, j)
			}
		}
	}

	fmt.Println(sumOfUsedSquares, areas)
}

func markSquareAndNeighboursVisited(grid [][]int, x, y int) {
	if x < 0 || x >= len(grid) || y < 0 || y >= len(grid[x]) {
		return
	}
	if grid[x][y] == 1 {
		grid[x][y] = 0

		markSquareAndNeighboursVisited(grid, x-1, y)
		markSquareAndNeighboursVisited(grid, x+1, y)
		markSquareAndNeighboursVisited(grid, x, y-1)
		markSquareAndNeighboursVisited(grid, x, y+1)
	}
}

func convertHexToBinaryString(hexString string) string {
	values, _ := hex.DecodeString(hexString)
	binary := ""
	for _, v := range values {
		binary += fmt.Sprintf("%08b", v)
	}
	return binary
}
