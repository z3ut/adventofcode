package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"

func main() {
	firewall := getFirewall(inputFileName)
	tripSeverity, isCaught := getTripSeverity(0, firewall)
	waiteTime := 0

	for isCaught {
		waiteTime++
		isCaught = isCaughtOnTrip(waiteTime, firewall)
	}

	fmt.Printf("%v\n%v\n", tripSeverity, waiteTime)
}

func isCaughtOnTrip(firstStepTime int, firewall []int) bool {
	for i := 0; i < len(firewall); i++ {
		if firewall[i] == 0 {
			continue
		}

		if isCaughtByScanner(i+firstStepTime, firewall[i]) {
			return true
		}
	}

	return false
}

func getTripSeverity(firstStepTime int, firewall []int) (int, bool) {
	tripSeverity := 0
	hasBeenCaght := false

	for i := 0; i < len(firewall); i++ {
		if firewall[i] == 0 {
			continue
		}

		if isCaughtByScanner(i+firstStepTime, firewall[i]) {
			hasBeenCaght = true
			tripSeverity += i * firewall[i]
		}
	}

	return tripSeverity, hasBeenCaght
}

func isCaughtByScanner(time, scannerRange int) bool {
	return math.Mod(float64(time), float64(scannerRange*2-2)) == 0
}

func getFirewall(fileName string) []int {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var firewall []int
	rows := strings.Split(string(data), "\r\n")

	for _, row := range rows {
		values := strings.Fields(row)

		depth, err := strconv.Atoi(strings.Trim(values[0], ":"))
		if err != nil {
			panic("Error parsing string value as int")
		}

		layerRange, err := strconv.Atoi(values[1])
		if err != nil {
			panic("Error parsing string value as int")
		}

		newFirewall := make([]int, depth+1)
		copy(newFirewall, firewall)
		newFirewall[depth] = layerRange
		firewall = newFirewall
	}

	return firewall
}
