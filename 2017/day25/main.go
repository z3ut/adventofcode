package main

import (
	"fmt"
)

type State struct {
	zero Action
	one  Action
}

type Action struct {
	write     int
	move      int
	nextState *State
}

const numberOfIterations = 12261543

func main() {
	tape := make(map[int]int)

	a := State{Action{1, 1, nil}, Action{0, -1, nil}}
	b := State{Action{1, -1, nil}, Action{1, 1, nil}}
	c := State{Action{1, 1, nil}, Action{0, -1, nil}}
	d := State{Action{1, -1, nil}, Action{1, -1, nil}}
	e := State{Action{1, 1, nil}, Action{1, 1, nil}}
	f := State{Action{1, 1, nil}, Action{1, 1, nil}}

	a.zero.nextState = &b
	a.one.nextState = &c
	b.zero.nextState = &a
	b.one.nextState = &c
	c.zero.nextState = &a
	c.one.nextState = &d
	d.zero.nextState = &e
	d.one.nextState = &c
	e.zero.nextState = &f
	e.one.nextState = &a
	f.zero.nextState = &a
	f.one.nextState = &e

	currentState := a
	currentPosition := 0

	for i := 0; i < numberOfIterations; i++ {
		var action Action
		if tape[currentPosition] == 0 {
			action = currentState.zero
		} else {
			action = currentState.one
		}

		tape[currentPosition] = action.write
		currentPosition += action.move
		currentState = *action.nextState
	}

	checksum := 0

	for _, v := range tape {
		checksum += v
	}

	fmt.Println(checksum)
}
