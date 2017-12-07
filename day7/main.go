package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const fileName = "input.txt"

type TowerInput struct {
	name          string
	weight        int
	subTowerNames []string
}

type Tower struct {
	name      string
	weight    int
	subTowers []Tower
}

func main() {
	inputTowers := getInputTowers(fileName)
	rootTower := getRootTower(inputTowers)
	root := createTower(rootTower, inputTowers)
	requiredWeight := getRequiredWeightOfUnbalancedTower(root)
	fmt.Printf("%v\n%v\n", root.name, requiredWeight)
}

func getInputTowers(fileName string) []TowerInput {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var towers []TowerInput

	for _, row := range strings.Split(string(data), "\n") {
		tower := TowerInput{}
		inputValues := strings.Fields(row)
		weight, err := strconv.Atoi(strings.Trim(inputValues[1], "()"))

		if err != nil {
			panic("Error parsing string value as int")
		}

		tower.name = inputValues[0]
		tower.weight = weight

		if len(inputValues) > 2 {
			for _, subtowerName := range inputValues[3:] {
				tower.subTowerNames = append(tower.subTowerNames, strings.Trim(subtowerName, ","))
			}
		}

		towers = append(towers, tower)
	}

	return towers
}

func getRootTower(towers []TowerInput) TowerInput {
	for _, potentialRoot := range towers {
		isExistLinksToPotentialRoot := false
		for _, tower := range towers {
			if isArrayInclude(tower.subTowerNames, potentialRoot.name) {
				isExistLinksToPotentialRoot = true
				break
			}
		}
		if !isExistLinksToPotentialRoot {
			return potentialRoot
		}
	}
	panic("Wrong towers on input without root")
}

func createTower(towerInput TowerInput, towers []TowerInput) Tower {
	tower := Tower{towerInput.name, towerInput.weight, []Tower{}}

	for _, t := range towers {
		for _, subTowerName := range towerInput.subTowerNames {
			if t.name == subTowerName {
				tower.subTowers = append(tower.subTowers, createTower(t, towers))
			}
		}
	}

	return tower
}

func walkAndPrintTower(tower Tower, level int) {
	fmt.Printf("%v %v %v\n", strings.Repeat(" ", level), tower.name, tower.weight)
	for _, t := range tower.subTowers {
		walkAndPrintTower(t, level+3)
	}
}

func getRequiredWeightOfUnbalancedTower(rootTower Tower) int {
	unbalancedTower := rootTower
	unbalancedTowers := unbalancedTower.subTowers
	isUnbalancedTowers := isTowersUnbalanced(unbalancedTowers)
	requiredWeight := 0

	for isUnbalancedTowers {
		unbalancedTower, requiredWeight = getUnbalancedTowerAndRequiredWeight(unbalancedTowers)
		unbalancedTowers = unbalancedTower.subTowers
		isUnbalancedTowers = isTowersUnbalanced(unbalancedTowers)
	}

	return requiredWeight + unbalancedTower.weight - getTowerWeight(unbalancedTower)
}

func isTowersUnbalanced(towers []Tower) bool {
	for _, t := range towers {
		if towers[0].weight != t.weight {
			return true
		}
	}
	return false
}

func getUnbalancedTowerAndRequiredWeight(towers []Tower) (Tower, int) {
	var towerWeights []int
	for _, t := range towers {
		towerWeights = append(towerWeights, getTowerWeight(t))
	}

	for i, uniqueWeightCandidate := range towerWeights {
		isNotEqualOnce := false
		for _, requiredWeightCandidate := range towerWeights {
			if uniqueWeightCandidate != requiredWeightCandidate {
				if isNotEqualOnce {
					return towers[i], requiredWeightCandidate
				}
				isNotEqualOnce = true
			}
		}
	}
	panic("All towers are ordered")
}

func getTowerWeight(tower Tower) int {
	weight := tower.weight
	for _, t := range tower.subTowers {
		weight += getTowerWeight(t)
	}
	return weight
}

func isArrayInclude(array []string, elem string) bool {
	for _, e := range array {
		if e == elem {
			return true
		}
	}
	return false
}
