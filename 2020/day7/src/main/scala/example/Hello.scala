import scala.io.Source

object Hello extends App {
  val bags: Map[String, Array[(String, Int)]] =
    Source
      .fromFile("input.txt")
      .mkString
      .split("\n")
      .map(_.split(" "))
      .map(parts => (
        parts(0) + " " + parts(1),
        parts
          .drop(4)
          .grouped(4)
          .filter(_(0) != "no")
          .map(p => (p(1) + " " + p(2), p(0).toInt))
          .toArray))
      .toMap

  def isCanContainBag(bag: String, searchingBag: String): Boolean =
    bags(bag).exists(c => c._1 == searchingBag || isCanContainBag(c._1, searchingBag))

  def countInsideBags(bag: String): Int =
    bags(bag).map(c => c._2 + c._2 * countInsideBags(c._1)).sum

  val taskBagName = "shiny gold"
  
  println(bags.count(b => isCanContainBag(b._1, taskBagName)))
  println(countInsideBags(taskBagName))
}
