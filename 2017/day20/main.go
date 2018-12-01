package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

const inputFileName = "input.txt"
const numberOfIterations = 1000

type Particle struct {
	coordX int
	coordY int
	coordZ int

	velocityX int
	velocityY int
	velocityZ int

	accelerationX int
	accelerationY int
	accelerationZ int
}

func main() {
	particles := getParticles(inputFileName)

	for i := 0; i < numberOfIterations; i++ {
		particles = performStep(particles)
	}

	closestToZeroParticleIndex := 0
	closestToZeroParticle := particles[0]

	for i, p := range particles {
		if getManhattanDistanceToZero(p) < getManhattanDistanceToZero(closestToZeroParticle) {
			closestToZeroParticleIndex = i
			closestToZeroParticle = p
		}
	}

	fmt.Println(closestToZeroParticleIndex)

	particles = getParticles(inputFileName)

	for i := 0; i < numberOfIterations; i++ {
		particles = performStep(particles)

		collidedIndexes := getCollidedIndexes(particles)

		for index := len(collidedIndexes) - 1; index >= 0; index-- {
			particles = append(particles[:collidedIndexes[index]], particles[collidedIndexes[index]+1:]...)
		}
	}

	fmt.Println(len(particles))
}

func performStep(particles []Particle) []Particle {
	for i := 0; i < len(particles); i++ {
		particles[i].velocityX += particles[i].accelerationX
		particles[i].velocityY += particles[i].accelerationY
		particles[i].velocityZ += particles[i].accelerationZ

		particles[i].coordX += particles[i].velocityX
		particles[i].coordY += particles[i].velocityY
		particles[i].coordZ += particles[i].velocityZ
	}

	return particles
}

func getCollidedIndexes(particles []Particle) []int {
	var collededIndexes []int

	for p1i, p1 := range particles {
		for p2i, p2 := range particles {
			if p1i == p2i {
				continue
			}

			if p1.coordX == p2.coordX && p1.coordY == p2.coordY && p1.coordZ == p2.coordZ {
				collededIndexes = appendIfNotIncluded(collededIndexes, p1i)
				collededIndexes = appendIfNotIncluded(collededIndexes, p2i)
				continue
			}
		}
	}

	return collededIndexes
}

func appendIfNotIncluded(array []int, value int) []int {
	for _, a := range array {
		if a == value {
			return array
		}
	}
	return append(array, value)
}

func getManhattanDistanceToZero(particle Particle) int {
	return int(math.Abs(float64(particle.coordX)) +
		math.Abs(float64(particle.coordY)) + math.Abs(float64(particle.coordZ)))
}

func getParticles(fileName string) []Particle {
	data, err := ioutil.ReadFile(fileName)
	if err != nil {
		panic("Error while reading file")
	}

	var particles []Particle

	for _, row := range strings.Split(string(data), "\n") {
		particle := Particle{}
		parts := strings.Fields(row)

		coords := strings.Split(parts[0][3:len(parts[0])-2], ",")
		velocities := strings.Split(parts[1][3:len(parts[1])-2], ",")
		accelerations := strings.Split(parts[2][3:len(parts[2])-1], ",")

		var err error

		particle.coordX, err = strconv.Atoi(coords[0])
		particle.coordY, err = strconv.Atoi(coords[1])
		particle.coordZ, err = strconv.Atoi(coords[2])

		particle.velocityX, err = strconv.Atoi(velocities[0])
		particle.velocityY, err = strconv.Atoi(velocities[1])
		particle.velocityZ, err = strconv.Atoi(velocities[2])

		particle.accelerationX, err = strconv.Atoi(accelerations[0])
		particle.accelerationY, err = strconv.Atoi(accelerations[1])
		particle.accelerationZ, err = strconv.Atoi(accelerations[2])

		if err != nil {
			panic("Error converting string to number")
		}

		particles = append(particles, particle)
	}

	return particles
}
