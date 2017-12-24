package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"
const bridgeStartPort = 0

type Component struct {
	portA int
	portB int
}

func main() {
	components := getComponents(inputFileName)
	var validBridges [][]Component

	for i, component := range components {
		isCanConnect, portNextSide := isComponentCanConnectAndGetOutputPort(component, bridgeStartPort)

		if !isCanConnect {
			continue
		}

		currentBridge := []Component{component}
		validBridges = append(validBridges, currentBridge)
		availableComponents := getComponentsWithoutPosition(components, i)
		newValidBridges := getValidBridges(portNextSide, currentBridge, availableComponents)
		validBridges = append(validBridges, newValidBridges...)
	}

	maxStrength := 0
	maxLength := 0
	maxStrengthForMaxLength := 0

	for _, bridge := range validBridges {
		currentStrength := 0

		for _, b := range bridge {
			currentStrength += b.portA + b.portB
		}

		if currentStrength > maxStrength {
			maxStrength = currentStrength
		}

		if len(bridge) >= maxLength && currentStrength >= maxStrengthForMaxLength {
			maxStrengthForMaxLength = currentStrength
			maxLength = len(bridge)
		}
	}

	fmt.Println(maxStrength, maxStrengthForMaxLength)
}

func isComponentCanConnectAndGetOutputPort(component Component, port int) (bool, int) {
	if component.portA == port {
		return true, component.portB
	}
	if component.portB == port {
		return true, component.portA
	}
	return false, 0
}

func getValidBridges(port int, currentBridge, availabelComponents []Component) [][]Component {

	var validBridges [][]Component

	for i, component := range availabelComponents {
		isCanConnect, portNextSide := isComponentCanConnectAndGetOutputPort(component, port)

		if !isCanConnect {
			continue
		}

		newCurrentBridge := append([]Component(nil), currentBridge...)
		newCurrentBridge = append(newCurrentBridge, component)
		validBridges = append(validBridges, newCurrentBridge)
		newAvailableComponents := getComponentsWithoutPosition(availabelComponents, i)
		newAvailableBridges := getValidBridges(portNextSide, newCurrentBridge, newAvailableComponents)
		validBridges = append(validBridges, newAvailableBridges...)
	}

	return validBridges
}

func getComponentsWithoutPosition(components []Component, position int) []Component {
	newComponents := append([]Component(nil), components[:position]...)
	return append(newComponents, components[position+1:]...)
}

func getComponents(fileName string) []Component {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var components []Component

	for _, row := range strings.Split(string(data), "\r\n") {
		portValues := strings.Split(row, "/")

		component := Component{}

		var err error

		component.portA, err = strconv.Atoi(portValues[0])
		if err != nil {
			panic("Error converting string to number")
		}

		component.portB, err = strconv.Atoi(portValues[1])
		if err != nil {
			panic("Error converting string to number")
		}

		components = append(components, component)
	}

	return components
}
