import scala.io.Source
import scala.collection.mutable.Map

object Hello extends App {
  val adapters: Array[Int] =
    Source
      .fromFile("input.txt")
      .getLines
      .map(_.toInt)
      .toArray
      .sorted

  val diffs = (0 +: adapters.dropRight(1)).zip(adapters).map{ case (a1, a2) => a2 - a1 }

  println(diffs.count(_ == 1) * (diffs.count(_ == 3) + 1))

  def genNumberOfVariants(adapters: Array[Int], adapter: Int, dict: Map[Int, BigInt]): BigInt =
    if (adapters.last == adapter)
      BigInt(1)
    else 
      adapters
        .filter(a => adapter < a && a <= adapter + 3)
        .map(a => dict.getOrElseUpdate(a, genNumberOfVariants(adapters, a, dict)))
        .sum

  println(genNumberOfVariants((0 +: adapters), 0, Map[Int, BigInt]()))
}
