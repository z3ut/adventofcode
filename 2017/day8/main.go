package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const fileName = "input.txt"

type Instruction struct {
	register          string
	command           string
	value             int
	conditionRegister string
	condition         string
	conditionValue    int
}

var registers = make(map[string]int)

func main() {
	instructions := getInstructions(fileName)

	maxValueDuringWork := getMaxValueFromRegisters(registers)

	for _, inst := range instructions {
		// < > == != <= >=
		switch inst.condition {
		case "<":
			if getRegisterValue(inst.conditionRegister) < inst.conditionValue {
				executeInstruction(inst.register, inst.command, inst.value)
			}
		case ">":
			if getRegisterValue(inst.conditionRegister) > inst.conditionValue {
				executeInstruction(inst.register, inst.command, inst.value)
			}
		case "==":
			if getRegisterValue(inst.conditionRegister) == inst.conditionValue {
				executeInstruction(inst.register, inst.command, inst.value)
			}
		case "!=":
			if getRegisterValue(inst.conditionRegister) != inst.conditionValue {
				executeInstruction(inst.register, inst.command, inst.value)
			}
		case "<=":
			if getRegisterValue(inst.conditionRegister) <= inst.conditionValue {
				executeInstruction(inst.register, inst.command, inst.value)
			}
		case ">=":
			if getRegisterValue(inst.conditionRegister) >= inst.conditionValue {
				executeInstruction(inst.register, inst.command, inst.value)
			}
		default:
			panic("Not expected condition")
		}
		registerNewValue := getRegisterValue(inst.register)
		if registerNewValue > maxValueDuringWork {
			maxValueDuringWork = registerNewValue
		}
	}

	maxValue := getMaxValueFromRegisters(registers)

	fmt.Printf("%v %v\n", maxValue, maxValueDuringWork)
}

func getInstructions(fileName string) []Instruction {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var instructions []Instruction

	for _, row := range strings.Split(string(data), "\n") {
		instruction := Instruction{}
		inputValues := strings.Fields(row)

		instruction.register = inputValues[0]
		instruction.command = inputValues[1]
		instruction.conditionRegister = inputValues[4]
		instruction.condition = inputValues[5]

		value, err := strconv.Atoi(inputValues[2])
		if err != nil {
			panic("Error parsing string value as int")
		}
		instruction.value = value

		conditionValue, err := strconv.Atoi(inputValues[6])
		if err != nil {
			panic("Error parsing string value as int")
		}
		instruction.conditionValue = conditionValue

		instructions = append(instructions, instruction)
	}

	return instructions
}

func getRegisterValue(register string) int {
	value, initialized := registers[register]
	if !initialized {
		return 0
	}
	return value
}

func setRegisterValue(register string, value int) {
	registers[register] = value
}

func executeInstruction(register, command string, value int) {
	registerCurrentValue := getRegisterValue(register)
	switch command {
	case "inc":
		setRegisterValue(register, registerCurrentValue+value)
	case "dec":
		setRegisterValue(register, registerCurrentValue-value)
	default:
		panic("Unexpected command")
	}
}

func getMaxValueFromRegisters(registers map[string]int) int {
	var maxValue int

	for _, maxValue = range registers {
		break
	}

	for _, value := range registers {
		if maxValue < value {
			maxValue = value
		}
	}

	return maxValue
}
