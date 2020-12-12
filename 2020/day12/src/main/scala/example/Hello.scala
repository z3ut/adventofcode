import scala.io.Source

import scala.math.{cos, sin, toRadians, round}

object Hello extends App {
  var instructions: Array[String] =
    Source
      .fromFile("input.txt")
      .getLines
      .toArray

  var direction = 90
  var east = 0
  var north = 0

  instructions.foreach(ins => {
    val value = ins.drop(1).toInt
    ins(0) match {
      case 'N' => north += value
      case 'S' => north -= value
      case 'E' => east += value
      case 'W' => east -= value
      case 'L' => direction = (360 + direction - value) % 360
      case 'R' => direction = (direction + value) % 360
      case 'F' => {
        direction match {
          case 0 => north += value
          case 90 => east += value
          case 180 => north -= value
          case 270 => east -= value
        }
      }
    }
  })

  println(north.abs + east.abs)


  var east2 = 0
  var north2 = 0
  var waypointNorth = 1
  var waypointEast = 10

  instructions.foreach(ins => {
    val value = ins.drop(1).toInt
    ins(0) match {
      case 'N' => waypointNorth += value
      case 'S' => waypointNorth -= value
      case 'E' => waypointEast += value
      case 'W' => waypointEast -= value
      case 'L' | 'R' => {
        val degreeRad = toRadians(if (ins(0) == 'L') value else -value)
        val newWaypointEast = round(waypointEast * cos(degreeRad) - waypointNorth * sin(degreeRad)).toInt
        val newWaypointNorth = round(waypointEast * sin(degreeRad) + waypointNorth * cos(degreeRad)).toInt

        waypointEast = newWaypointEast
        waypointNorth = newWaypointNorth
      }
      case 'F' => {
        north2 += value * waypointNorth
        east2 += value * waypointEast
      }
    }
  })

  println(north2.abs + east2.abs)
}
