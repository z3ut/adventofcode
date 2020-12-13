package example

import scala.util.{Success, Try}
import scala.math

object Hello extends App {
  val currentTimestamp = 1000434
  val buses = "17,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,983,x,29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,x,x,397,x,x,x,x,x,37,x,x,x,x,x,x,13"

  val departure =
    buses
      .split(',')
      .filter(_ != "x")
      .map(_.toInt)
      .map(id => (id, id - currentTimestamp % id))
      .sortBy(_._2)
      .head

  println(departure._1 * departure._2)

  val busRemainders =
    buses
      .split(',')
      .zipWithIndex
      .map{ case (id, i) => (id, i) }
      .filter(_._1 != "x")
      .map{ case (id, i) => (BigInt(id), BigInt(id.toInt - i)) }

  val result = chineseRemainder(busRemainders.map(_._1).toList, busRemainders.map(_._2).toList)
  println(result)


  // https://rosettacode.org/wiki/Chinese_remainder_theorem#Scala
  def chineseRemainder(n: List[BigInt], a: List[BigInt]): Option[BigInt] = {
    require(n.size == a.size)
    val prod = n.product
 
    def iter(n: List[BigInt], a: List[BigInt], sm: BigInt): BigInt = {
      def mulInv(a: BigInt, b: BigInt): BigInt = {
        def loop(a: BigInt, b: BigInt, x0: BigInt, x1: BigInt): BigInt = {
          if (a > 1) loop(b, a % b, x1 - (a / b) * x0, x0) else x1
        }
 
        if (b == 1) 1
        else {
          val x1 = loop(a, b, 0, 1)
          if (x1 < 0) x1 + b else x1
        }
      }
 
      if (n.nonEmpty) {
        val p = prod / n.head
 
        iter(n.tail, a.tail, sm + a.head * mulInv(p, n.head) * p)
      } else sm
    }
 
    Try {
      iter(n, a, 0) % prod
    } match {
      case Success(v) => Some(v)
      case _          => None
    }
  }
}
