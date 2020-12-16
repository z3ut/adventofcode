import scala.io.Source

object Hello extends App {
  val myTicket: Array[Int] = Array(73,101,67,97,149,53,89,113,79,131,71,127,137,61,139,103,83,107,109,59)
  val departureFieldsCount = 6

  val tickets: Array[Array[Int]] =
    Source
      .fromFile("tickets.txt")
      .getLines
      .map(_.split(',').map(_.toInt))
      .toArray

  val rules: Array[Array[(Int, Int)]] =
    Source
      .fromFile("rules.txt")
      .getLines
      .map(line =>
        line
          .split(':')
          .last
          .split(" or ")
          .map(_.split('-'))
          .map(a => (a(0).trim.toInt, a(1).trim.toInt)))
      .toArray
  
  val allRules = 
    rules
      .flatMap(_.toList)
      .toArray

  def isValidValue(value: Int, rules: Array[(Int, Int)]): Boolean =
      rules.exists{ case (from, to) => from <= value && value <= to }

  val ticketScanningErrorRate =
    tickets
      .map(t => t.filter(v => !isValidValue(v, allRules)).sum)
      .sum
  
  println(ticketScanningErrorRate)

  val validTickets =
    tickets
      .filter(t => t.forall(v => isValidValue(v, allRules)))
  
  val possibleIndexes = rules
    .map(rule =>
      (0 until myTicket.length)
        .filter(position =>
          validTickets.forall(t => isValidValue(t(position), rule)))
        .toArray)
    .zipWithIndex
    .sortBy(_._1.length)

  val departureProduct =
    (0 until possibleIndexes.length)
      .map(i =>(
        possibleIndexes(i)._1.find(index =>
          !possibleIndexes.take(i).map(_._1).flatMap(_.toList).contains(index)),
        possibleIndexes(i)._2))
      .sortBy(_._2)
      .take(departureFieldsCount)
      .map{ case (n, _) => BigInt(myTicket(n.get))}
      .product

  println(departureProduct)
}
