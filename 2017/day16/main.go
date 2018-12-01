package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"
const numberOfDances = 1000000000

func main() {
	commands := getCommands(inputFileName)

	var programs []rune
	for i := 'a'; i <= 'p'; i++ {
		programs = append(programs, i)
	}

	danceCycle := getDanceCycle(programs, commands)

	programs = performeDance(programs, commands)
	printPrograms(programs)

	for i := 1; i < int(math.Mod(float64(numberOfDances), float64(danceCycle))); i++ {
		programs = performeDance(programs, commands)
	}

	printPrograms(programs)
}

func getDanceCycle(programsStartPosition []rune, commands []string) int {
	programs := make([]rune, len(programsStartPosition))
	copy(programs, programsStartPosition)

	danceCycle := 0

	for {
		programs = performeDance(programs, commands)
		danceCycle++

		isRepeat := true
		for i := range programs {
			if programs[i] != programsStartPosition[i] {
				isRepeat = false
				break
			}
		}

		if isRepeat {
			return danceCycle
		}
	}
}

func performeDance(programsPosition []rune, commands []string) []rune {
	programs := make([]rune, len(programsPosition))
	copy(programs, programsPosition)

	for _, cmd := range commands {
		switch cmd[0] {
		case 's':
			shiftNumber, err := strconv.Atoi(cmd[1:])
			if err != nil {
				panic("Error converting string to number")
			}

			programs = append(programs[len(programs)-shiftNumber:], programs[:len(programs)-shiftNumber]...)
		case 'x':
			numbers := strings.Split(cmd[1:], "/")
			number1, err1 := strconv.Atoi(numbers[0])
			number2, err2 := strconv.Atoi(numbers[1])

			if err1 != nil || err2 != nil {
				panic("Error converting string to number")
			}

			programs[number1], programs[number2] = programs[number2], programs[number1]
		case 'p':
			programNames := strings.Split(cmd[1:], "/")
			program1 := programNames[0]
			program2 := programNames[1]

			var number1, number2 int

			for i, p := range programs {
				if string(p) == program1 {
					number1 = i
				}

				if string(p) == program2 {
					number2 = i
				}
			}

			programs[number1], programs[number2] = programs[number2], programs[number1]
		default:
			panic("Unknown command")
		}
	}

	return programs
}

func getCommands(fileName string) []string {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}
	return strings.Split(string(data), ",")
}

func printPrograms(programs []rune) {
	for _, p := range programs {
		fmt.Printf("%v", string(p))
	}
	fmt.Println()
}
