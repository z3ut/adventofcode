import scala.io.Source
import scala.collection.mutable.Map

case class Coords(x: Int, y: Int, z: Int)

object Hello extends App {
  val numberOfCycles = 6

  var grid3 = Map[(Int, Int, Int), Char]()
  var grid4 = Map[(Int, Int, Int, Int), Char]()

  Source
    .fromFile("input.txt")
    .getLines
    .zipWithIndex
    .foreach{ case (string, y) =>
      string
        .zipWithIndex
        .foreach{ case (c, x) => {
          grid3((x, y, 0)) = c
          grid4((x, y, 0, 0)) = c 
        }}}

  def getNeighbours3(coords: (Int, Int, Int)): IndexedSeq[(Int, Int, Int)] = {
    for {
      x <- coords._1 - 1 to coords._1 + 1
      y <- coords._2 - 1 to coords._2 + 1
      z <- coords._3 - 1 to coords._3 + 1
      if x != coords._1 || y != coords._2 || z != coords._3
    } yield (x, y, z)
  }

  def getNeighbours4(coords: (Int, Int, Int, Int)): IndexedSeq[(Int, Int, Int, Int)] = {
    for {
      x <- coords._1 - 1 to coords._1 + 1
      y <- coords._2 - 1 to coords._2 + 1
      z <- coords._3 - 1 to coords._3 + 1
      w <- coords._4 - 1 to coords._4 + 1
      if x != coords._1 || y != coords._2 || z != coords._3 || w != coords._4
    } yield (x, y, z, w)
  }

  def runCycle[A](grid: Map[A, Char], getNeighbours: (A) => IndexedSeq[A]): Map[A, Char] = {
    val newGrid = Map[A, Char]()

    val possibleNewActiveCubes =
      grid
        .keys
        .map(c => getNeighbours(c))
        .flatten

    possibleNewActiveCubes.foreach(coords => {
      val activeNeighboursCount =
        getNeighbours(coords)
          .count(c => grid.getOrElse(c, '.') == '#')

      if (grid.getOrElse(coords, '.') == '#') {
        if (activeNeighboursCount == 2 || activeNeighboursCount == 3)
          newGrid(coords) = '#'
      } else {
        if (activeNeighboursCount == 3)
          newGrid(coords) = '#'
      }
    })

    newGrid 
  }


  for (i <- 1 to numberOfCycles)
    grid3 = runCycle(grid3, getNeighbours3)

  println(grid3.values.count(_== '#'))


  for (i <- 1 to numberOfCycles)
    grid4 = runCycle(grid4, getNeighbours4)

  println(grid4.values.count(_== '#'))
}