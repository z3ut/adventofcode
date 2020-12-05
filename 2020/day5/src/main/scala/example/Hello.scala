import scala.io.Source

object Hello extends App {
  val seatIds =
    Source
      .fromFile("input.txt")
      .getLines
      .toArray
      .map(s => {
        val row = Integer.parseInt(s.substring(0, 7).replace("F", "0").replace("B", "1"), 2)
        val column = Integer.parseInt(s.substring(7).replace("L", "0").replace("R", "1"), 2)
        row * 8 + column
      })

  println(seatIds.max)
 
  val seatId = (seatIds.min to seatIds.max).find(!seatIds.contains(_))
  println(seatId)
}
