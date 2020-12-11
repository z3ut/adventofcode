import scala.io.Source

import scala.math.{max, min}

object Hello extends App {
  var seats: Array[String] =
    Source
      .fromFile("input.txt")
      .getLines
      .toArray

  def getNeighbours1(seats: Array[String], seatX: Int, seatY: Int): Array[Char] = {
    (for (xx <- (seatX - 1 to seatX + 1); yy <- (seatY - 1 to seatY + 1)) yield (xx, yy))
      .filter{ case (x, y) =>
        (seatX != x || seatY != y) && x >= 0 && y >= 0 &&
          x < seats(0).length && y < seats.length }
      .map{ case (x, y) => seats(y)(x) }
      .toArray
  }

  def turn(
    seats: Array[String],
    occupiedNeighborSeatsCountToLeave: Int,
    getNeighbours: (Array[String], Int, Int) => Array[Char]) = {

    seats.zipWithIndex.map{ case (row, y) => row.zipWithIndex.map{ case (place, x) => {
      place match {
        case '.' => '.'
        case 'L' => if (getNeighbours(seats, x, y).count(_ == '#') == 0) '#' else 'L'
        case '#' => if (getNeighbours(seats, x, y).count(_ == '#') >=
          occupiedNeighborSeatsCountToLeave) 'L' else '#'
      }
    }}.mkString("")}
  }

  def findFinalOccupiedSeatsCount(
    seats: Array[String],
    occupiedNeighborSeatsCountToLeave: Int,
    getNeighbours: (Array[String], Int, Int) => Array[Char]): Int = {
    
    var currentSeats = seats.clone
    var previousSeats = seats.clone

    do {
      previousSeats = currentSeats.clone
      currentSeats = turn(currentSeats, occupiedNeighborSeatsCountToLeave, getNeighbours)
    } while(!currentSeats.sameElements(previousSeats))

    currentSeats.map(row => row.count(c => c == '#')).sum
  }

  println(findFinalOccupiedSeatsCount(seats, 4, getNeighbours1))


  def getNeighbours2(seats: Array[String], seatX: Int, seatY: Int): Array[Char] = {
    def getFirstVisibleSeat (seats: IndexedSeq[Char]) =
      seats.find(c => c == '#' || c == 'L').getOrElse('.')
    Array(
      getFirstVisibleSeat((seatY - 1 to 0 by -1).map(y => seats(y)(seatX))),
      getFirstVisibleSeat(
        (seatX + 1 until seats(seatY).length)
          .zip(seatY - 1 to 0 by -1)
          .map{ case (x, y) => seats(y)(x) }),
      getFirstVisibleSeat((seatX + 1 until seats(seatY).length).map(x => seats(seatY)(x))),
      getFirstVisibleSeat(
        (seatX + 1 until seats(seatY).length)
          .zip(seatY + 1 until seats.length)
          .map{ case (x, y) => seats(y)(x) }
      ),
      getFirstVisibleSeat((seatY + 1 until seats.length).map(y => seats(y)(seatX))),
      getFirstVisibleSeat(
        (seatX - 1 to 0 by -1)
          .zip(seatY + 1 until seats.length)
          .map{ case (x, y) => seats(y)(x) }
      ),
      getFirstVisibleSeat((seatX - 1 to 0 by -1).map(x => seats(seatY)(x))),
      getFirstVisibleSeat(
        (seatX - 1 to 0 by -1)
          .zip(seatY - 1 to 0 by -1)
          .map{ case (x, y) => seats(y)(x) }
      ),
    )
  }

  println(findFinalOccupiedSeatsCount(seats, 5, getNeighbours2))
}
