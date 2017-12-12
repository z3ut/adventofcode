package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"

type Program struct {
	id    int
	pipes []int
}

func main() {
	programs := getPrograms(inputFileName)
	var connectedProgramGroups [][]int

	for len(programs) > 0 {
		var programGroup []int
		programGroup, programs = getConnectedProgramGroupAndRemains(programs)
		connectedProgramGroups = append(connectedProgramGroups, programGroup)
	}

	fmt.Printf("%v\n%v\n", len(connectedProgramGroups[0]), len(connectedProgramGroups))
}

func getConnectedProgramGroupAndRemains(programs []Program) ([]int, []Program) {
	var connectedPrograms []int
	isNewProgramAdded := true

	for isNewProgramAdded {
		isNewProgramAdded = false

		for i := 0; i < len(programs); i++ {
			if len(connectedPrograms) == 0 || isIncludeProgram(connectedPrograms, programs[i]) {
				isNewProgramAdded = true
				for _, id := range programs[i].pipes {
					if !isIncludeValue(connectedPrograms, id) {
						connectedPrograms = append(connectedPrograms, id)
					}
				}
				programs = removeProgram(programs, i)
				i--
			}
		}
	}
	return connectedPrograms, programs
}

func isIncludeProgram(array []int, program Program) bool {
	for _, a := range array {
		if a == program.id {
			return true
		}
		for _, p := range program.pipes {
			if a == p {
				return true
			}
		}
	}
	return false
}

func isIncludeValue(array []int, value int) bool {
	for _, a := range array {
		if a == value {
			return true
		}
	}
	return false
}

func removeProgram(array []Program, position int) []Program {
	return append(array[:position], array[position+1:]...)
}

func getPrograms(fileName string) []Program {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var programs []Program
	rows := strings.Split(string(data), "\r\n")

	for _, row := range rows {
		values := strings.Fields(row)

		programId, err := strconv.Atoi(values[0])
		if err != nil {
			panic("Error parsing string value as int")
		}
		var pipes []int

		for _, p := range values[2:] {
			id, err := strconv.Atoi(strings.Trim(p, ","))
			if err != nil {
				panic("Error parsing string value as int")
			}
			pipes = append(pipes, id)
		}

		programs = append(programs, Program{programId, pipes})
	}

	return programs
}
