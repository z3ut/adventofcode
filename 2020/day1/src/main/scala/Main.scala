import scala.io.Source

object Main extends App {
  val filename = "input.txt"
  val entriesSum = 2020

  val entries = Source.fromFile(filename).getLines().map(_.toInt).toArray

  def findCombSumProduct(entries: Array[Int], combSize: Int, sum: Int) =
    entries.combinations(combSize).find(_.sum == sum).map(_.product)

  println(findCombSumProduct(entries, 2, entriesSum))
  println(findCombSumProduct(entries, 3, entriesSum))
}