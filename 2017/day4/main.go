package main

import (
	"fmt"
	"io/ioutil"
	"sort"
	"strings"
)

const inputFile = "input.txt"

type isValidPassphraceFunc func(passphrase []string) bool

func main() {
	passphrases := getPassphrases(inputFile)

	passphraseCheckers := []isValidPassphraceFunc{isPassphraseHasNoDublicatedWords}
	numberOfValidPasswordFirstTask := getNumberOfValidPassphrases(passphrases, passphraseCheckers)

	passphraseCheckers = append(passphraseCheckers, isPassphraseHasNoAnagrams)
	numberOfValidPasswordSecondTask := getNumberOfValidPassphrases(passphrases, passphraseCheckers)

	fmt.Printf("%v\n%v\n", numberOfValidPasswordFirstTask, numberOfValidPasswordSecondTask)
}

func getPassphrases(fileName string) [][]string {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var passphrases [][]string

	for _, row := range strings.Split(string(data), "\n") {
		passphrases = append(passphrases, strings.Fields(row))
	}

	return passphrases
}

func getNumberOfValidPassphrases(passphrases [][]string, isValidPassphraceCheckers []isValidPassphraceFunc) int {
	numberOfValidPassphrases := 0

	for _, passphrace := range passphrases {
		isValidPassphrace := true

		for _, passphraseChecker := range isValidPassphraceCheckers {
			if !passphraseChecker(passphrace) {
				isValidPassphrace = false
				break
			}
		}

		if isValidPassphrace {
			numberOfValidPassphrases++
		}
	}

	return numberOfValidPassphrases
}

func isPassphraseHasNoDublicatedWords(passphrase []string) bool {
	for i, word1 := range passphrase {
		for j, word2 := range passphrase {
			if i != j && word1 == word2 {
				return false
			}
		}
	}

	return true
}

func isPassphraseHasNoAnagrams(passphrase []string) bool {
	for i, word1 := range passphrase {
		for j, word2 := range passphrase {
			if i == j {
				continue
			}

			if sortStringAlphabetical(word1) == sortStringAlphabetical(word2) {
				return false
			}
		}
	}

	return true
}

func sortStringAlphabetical(input string) string {
	chars := strings.Split(input, "")
	sort.Strings(chars)
	return strings.Join(chars, "")
}
