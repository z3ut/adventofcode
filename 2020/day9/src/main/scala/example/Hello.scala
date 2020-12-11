import scala.io.Source
import scala.collection.mutable.ArrayBuffer

object Hello extends App {
  val input: Array[BigInt] =
    Source
      .fromFile("input.txt")
      .getLines
      .map(BigInt(_))
      .toArray

  val preambleSize = 25

  val position = input.zipWithIndex.drop(preambleSize).find{ case (n, i) =>
    !input
      .slice(i - preambleSize, i + preambleSize)
      .combinations(2)
      .exists(c => c(0) + c(1) == n)
  }

  val invalidNumber = position.get._1
  println(invalidNumber)


  var firstIndex = 0
  var lastIndex = 0

  input.zipWithIndex.takeWhile{ case (_, i) => {
    var totalSum: BigInt = 0
    firstIndex = i
    lastIndex = i

    input.drop(i).takeWhile(n => {
      totalSum += n
      lastIndex += 1
      totalSum < invalidNumber
    })

    totalSum != invalidNumber
  }}

  val numbers = input.slice(firstIndex, lastIndex)
  println(numbers.min + numbers.max)
}
