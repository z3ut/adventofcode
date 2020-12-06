import scala.io.Source

object Hello extends App {
  val answers =
    Source
      .fromFile("input.txt")
      .mkString
      .split("(\\r?\\n){2}")
      .map(_.split("\\r?\\n"))

  println(
    answers
      .map(group => ('a' to 'z').count(c => group.exists(s => s.contains(c))))
      .sum)

  println(
    answers
      .map(group => ('a' to 'z').count(c => group.forall(_.contains(c))))
      .sum)
}
