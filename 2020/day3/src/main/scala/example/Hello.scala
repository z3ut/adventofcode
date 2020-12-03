import scala.io.Source

object Hello extends App {
  val trees = Source.fromFile("input.txt").getLines().toArray

  def calcNumberOfTreesInSlope(trees: Array[String], right: Int, down: Int): Int =
    (0 to trees.length - 1 by down)
      .count(i => trees(i)(i / down * right % trees(i).length) == '#')

  val numberOfTrees = calcNumberOfTreesInSlope(trees, 3, 1)
  println(numberOfTrees)

  val multipliedNumberOfTrees =
    Array((1, 1), (3, 1), (5, 1), (7, 1), (1, 2))
      .map(p => BigInt(calcNumberOfTreesInSlope(trees, p._1, p._2)))
      .product
  println(multipliedNumberOfTrees)
}
