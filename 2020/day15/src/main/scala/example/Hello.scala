import scala.io.Source
import scala.collection.mutable.Map
import java.math.BigInteger

object Hello extends App {
  val input = Array(12,1,16,3,11,0)
  
  println(runGame(input, 2020))
  println(runGame(input, 30000000))
  
  def runGame(input: Array[Int], iterations: Int): Int = {
    var previous = input.last
    val lastTimeSpoken = Map[Int, Int]()
    input
      .dropRight(1)
      .zipWithIndex
      .foreach{ case (v, i) => lastTimeSpoken(v) = i + 1 }

    (input.length + 1 to iterations)
      .foreach(i => {
        if (lastTimeSpoken.contains(previous)) {
          val nextToSpeak = i - 1 - lastTimeSpoken(previous)
          lastTimeSpoken(previous) = i - 1
          previous = nextToSpeak
        } else {
          lastTimeSpoken(previous) = i - 1
          previous = 0
        }
      })

    previous
  }
}
