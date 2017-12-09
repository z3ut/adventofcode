package main

import (
	"fmt"
	"io/ioutil"
)

const fileName = "input.txt"

func main() {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}
	stream := string(data)

	currentScore := 0
	totalScore := 0
	garbageNoncancelledCount := 0
	isSkipNextChar := false
	isGarbage := false

	for _, char := range stream {
		if isSkipNextChar {
			isSkipNextChar = false
			continue
		}

		if char == '!' {
			isSkipNextChar = true
			continue
		}

		if isGarbage {
			if char == '>' {
				isGarbage = false
			} else {
				garbageNoncancelledCount++
			}
			continue
		}

		if char == '{' {
			currentScore++
			totalScore += currentScore
			continue
		}

		if char == '}' {
			currentScore--
			continue
		}

		if char == '<' {
			isGarbage = true
			continue
		}
	}

	fmt.Println(totalScore, garbageNoncancelledCount)
}
